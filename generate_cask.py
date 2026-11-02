#!/usr/bin/env python3
"""
Utility script to generate a Homebrew cask for a macOS .app distributed as a DMG.

The cask lists one DMG per CPU architecture (Apple Silicon and Intel) and
Homebrew installs the one matching the Mac.

Example:
    python generate_cask.py \\
        --name cruma \\
        --version 0.3.0-beta.3 \\
        --arm-url https://files.cruma.io/.../aarch64-apple-darwin/cruma.dmg \\
        --intel-url https://files.cruma.io/.../x86_64-apple-darwin/cruma.dmg \\
        --app-name "Cruma.app" \\
        --binary-name cruma \\
        --desc "Cruma tunnel agent" \\
        --homepage https://cruma.io
"""

from __future__ import annotations

import argparse
import hashlib
import os
import pathlib
import platform
import re
import shutil
import struct
import subprocess
import sys
import tempfile
import urllib.parse
import urllib.request

from artifact_urls import ARTIFACT_BASE


# Each architecture's DMG lives at exactly one place on files.cruma.io. Anything
# else (the other architecture, another channel, another version) is refused
# before anything is downloaded, so an arm64 DMG can never be offered to Intel Macs.
ARM_TARGET = "aarch64-apple-darwin"
INTEL_TARGET = "x86_64-apple-darwin"

# Mach-O cputype values (mach/machine.h) -> the names `lipo -archs` prints.
MACHO_CPU_TYPES = {0x01000007: "x86_64", 0x0100000C: "arm64"}
EXPECTED_MACHO_ARCH = {ARM_TARGET: "arm64", INTEL_TARGET: "x86_64"}


def expected_dmg_url(version: str, target: str, cask_name: str) -> str:
    return f"{ARTIFACT_BASE}/v{version}/{target}/{kebab_case(cask_name)}.dmg"


def check_dmg_url(url: str, version: str, target: str, cask_name: str) -> str | None:
    """Return an error message unless `url` is the DMG of `cask_name` built for `target`."""
    expected = expected_dmg_url(version, target, cask_name)
    if url != expected:
        return f"{target} DMG URL must be {expected}, got {url}"
    return None


def macho_archs(path: pathlib.Path) -> set[str]:
    """Architectures in a thin or fat Mach-O file; unknown CPU types are reported by number."""
    with path.open("rb") as handle:
        header = handle.read(8)
        if len(header) < 8:
            raise RuntimeError(f"not a Mach-O executable: {path}")
        magic = header[:4]
        if magic in (b"\xcf\xfa\xed\xfe", b"\xce\xfa\xed\xfe"):
            (cpu_type,) = struct.unpack("<I", header[4:8])
            return {MACHO_CPU_TYPES.get(cpu_type, f"cputype-{cpu_type:#x}")}
        if magic in (b"\xca\xfe\xba\xbe", b"\xca\xfe\xba\xbf"):
            (count,) = struct.unpack(">I", header[4:8])
            entry_size = 20 if magic == b"\xca\xfe\xba\xbe" else 32
            archs = set()
            for _ in range(count):
                entry = handle.read(entry_size)
                if len(entry) != entry_size:
                    raise RuntimeError(f"truncated Mach-O architecture table: {path}")
                (cpu_type,) = struct.unpack(">I", entry[:4])
                archs.add(MACHO_CPU_TYPES.get(cpu_type, f"cputype-{cpu_type:#x}"))
            return archs
    raise RuntimeError(f"not a Mach-O executable: {path}")


def kebab_case(name: str) -> str:
    tokens = re.split(r"[\s_]+", name.strip().lower())
    return "-".join(filter(None, tokens))


def download_file(url: str) -> pathlib.Path:
    parsed = urllib.parse.urlparse(url)
    suffix = pathlib.Path(parsed.path).suffix or ".bin"
    tmp_fd, tmp_path = tempfile.mkstemp(prefix="cask-asset-", suffix=suffix)
    os.close(tmp_fd)
    with urllib.request.urlopen(url) as response, open(tmp_path, "wb") as tmp_file:
        while True:
            chunk = response.read(8192)
            if not chunk:
                break
            tmp_file.write(chunk)
    return pathlib.Path(tmp_path)


def hash_file(path: pathlib.Path) -> str:
    sha256 = hashlib.sha256()
    with path.open("rb") as infile:
        for block in iter(lambda: infile.read(8192), b""):
            sha256.update(block)
    return sha256.hexdigest()


def run_checked(cmd: list[str], *, cwd: pathlib.Path | None = None) -> str:
    try:
        completed = subprocess.run(
            cmd,
            cwd=str(cwd) if cwd else None,
            check=True,
            text=True,
            capture_output=True,
        )
    except subprocess.CalledProcessError as exc:
        details = (exc.stdout or "") + (exc.stderr or "")
        raise RuntimeError(
            f"command failed ({exc.returncode}): {' '.join(cmd)}\n{details}".rstrip()
        ) from exc
    return completed.stdout + completed.stderr


def run_spctl_open_assess(dmg_path: pathlib.Path) -> None:
    try:
        print(run_checked(["spctl", "--assess", "--type", "open", "-vv", str(dmg_path)]).strip())
    except RuntimeError as exc:
        message = str(exc)
        if "source=Insufficient Context" not in message:
            raise
        print("spctl open assessment returned 'Insufficient Context' for the downloaded DMG; continuing with stapler and mounted app verification.")
        print(message)


NATIVE_MACHINES = {"arm64": {"arm64", "aarch64"}, "x86_64": {"x86_64", "amd64"}}


def host_runs_natively(expected_arch: str) -> bool:
    return platform.machine().lower() in NATIVE_MACHINES[expected_arch]


def verify_macos_artifact(
    dmg_path: pathlib.Path,
    app_name: str,
    binary_name: str,
    expected_arch: str,
    version: str,
) -> None:
    required_tools = ["spctl", "xcrun", "hdiutil", "codesign"]
    missing = [tool for tool in required_tools if shutil.which(tool) is None]
    if missing:
        raise RuntimeError(f"missing required macOS verification tools: {', '.join(missing)}")

    print(f"Verifying notarized {expected_arch} DMG with Gatekeeper...")
    print(run_checked(["codesign", "--verify", "--verbose=2", str(dmg_path)]).strip())
    run_spctl_open_assess(dmg_path)
    print(run_checked(["xcrun", "stapler", "validate", str(dmg_path)]).strip())

    with tempfile.TemporaryDirectory(prefix="cruma-cask-mount-") as mount_dir:
        try:
            print("Mounting DMG for app verification...")
            print(
                run_checked(
                    [
                        "hdiutil",
                        "attach",
                        "-readonly",
                        "-nobrowse",
                        "-mountpoint",
                        mount_dir,
                        str(dmg_path),
                    ]
                ).strip()
            )
            app_path = pathlib.Path(mount_dir) / app_name
            if not app_path.exists():
                raise RuntimeError(f"expected app bundle not found in DMG: {app_path}")

            print("Verifying app signature inside mounted DMG...")
            print(run_checked(["codesign", "--verify", "--deep", "--strict", "--verbose=2", str(app_path)]).strip())
            print(run_checked(["spctl", "--assess", "-vv", str(app_path)]).strip())

            binary_path = app_path / "Contents" / "MacOS" / binary_name
            archs = macho_archs(binary_path)
            if expected_arch not in archs:
                raise RuntimeError(
                    f"{binary_path} contains {sorted(archs)}, expected {expected_arch}"
                )
            print(f"Executable architectures: {', '.join(sorted(archs))}")

            if host_runs_natively(expected_arch):
                reported = run_checked([str(binary_path), "--version"]).strip()
                print(reported)
                if version not in reported:
                    raise RuntimeError(
                        f"`{binary_name} --version` printed {reported!r}, expected it to contain {version}"
                    )
            else:
                print(f"Skipping `--version`: this Mac cannot run {expected_arch} natively.")
        finally:
            subprocess.run(
                ["hdiutil", "detach", mount_dir],
                check=False,
                text=True,
                capture_output=True,
            )


def render_cask(
    cask_name: str,
    version: str,
    arm_sha256: str,
    intel_sha256: str,
    app_name: str,
    app_target: str,
    binary_name: str,
    binary_target: str,
    desc: str,
    homepage: str,
    clear_quarantine: bool,
) -> str:
    installed_app_name = app_target or app_name
    binary_path = f"#{{appdir}}/{installed_app_name}/Contents/MacOS/{binary_name}"
    app_clause = f'app "{app_name}"'
    if installed_app_name != app_name:
        app_clause = f'app "{app_name}", target: "{installed_app_name}"'
    binary_clause = f'binary "{binary_path}"'
    if binary_target != binary_name:
        binary_clause = f'binary "{binary_path}", target: "{binary_target}"'

    postflight = ""
    if clear_quarantine:
        postflight = f"""
  postflight do
    system_command "/usr/bin/xattr",
                   args: ["-drs", "com.apple.quarantine", "#{{appdir}}/{installed_app_name}"]
    system_command "/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister",
                   args: ["-f", "#{{appdir}}/{installed_app_name}"]
    system_command "/usr/bin/mdimport",
                   args: ["#{{appdir}}/{installed_app_name}"]
  end
"""
    else:
        postflight = f"""
  postflight do
    system_command "/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister",
                   args: ["-f", "#{{appdir}}/{installed_app_name}"]
    system_command "/usr/bin/mdimport",
                   args: ["#{{appdir}}/{installed_app_name}"]
  end
"""

    dmg_name = f"{kebab_case(cask_name)}.dmg"
    cask = f"""cask "{cask_name}" do
  arch arm: "{ARM_TARGET}", intel: "{INTEL_TARGET}"

  version "{version}"
  sha256 arm:   "{arm_sha256}",
         intel: "{intel_sha256}"

  url "{ARTIFACT_BASE}/v#{{version}}/#{{arch}}/{dmg_name}"

  name "{installed_app_name.removesuffix('.app')}"
  desc "{desc}"
  homepage "{homepage}"

  {app_clause}

  # Symlinks the binary into $(brew --prefix)/bin so `{binary_target}` works in the terminal
  {binary_clause}
{postflight}
end
"""
    return "\n".join(line.rstrip() for line in cask.strip("\n").splitlines()) + "\n"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Generate a Homebrew cask for a macOS DMG.")
    parser.add_argument("--name", required=True, help="Cask name (e.g. cruma)")
    parser.add_argument("--version", required=True, help="Semantic version string")
    parser.add_argument("--arm-url", required=True, help=f"Download URL for the Apple Silicon DMG ({ARM_TARGET})")
    parser.add_argument("--intel-url", required=True, help=f"Download URL for the Intel DMG ({INTEL_TARGET})")
    parser.add_argument("--app-name", required=True, help='Name of the .app inside the DMG (e.g. "Cruma.app")')
    parser.add_argument(
        "--app-target",
        help="Installed app name inside /Applications (defaults to --app-name)",
    )
    parser.add_argument("--binary-name", required=True, help="Name of the CLI binary inside Contents/MacOS/")
    parser.add_argument(
        "--binary-target",
        help="Installed CLI name inside Homebrew's bin/ (defaults to --binary-name)",
    )
    parser.add_argument("--desc", default="", help="One-line description")
    parser.add_argument("--homepage", default="https://example.com", help="Project homepage URL")
    parser.add_argument(
        "--output-dir",
        default="Casks",
        help="Directory where the cask file should be written (default: Casks)",
    )
    parser.add_argument(
        "--skip-verify",
        action="store_true",
        help="Skip macOS Gatekeeper/signature verification of the downloaded DMGs before writing the cask",
    )
    parser.add_argument(
        "--allow-quarantine-clear",
        action="store_true",
        help="Add an explicit postflight xattr quarantine-clear fallback to the generated cask",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    desc = args.desc or f"{args.name} tunnel agent"
    app_target = args.app_target or args.app_name
    binary_target = args.binary_target or args.binary_name

    base_dir = pathlib.Path(__file__).resolve().parent
    output_dir = pathlib.Path(args.output_dir)
    if not output_dir.is_absolute():
        output_dir = (base_dir / output_dir).resolve()
    output_dir.mkdir(parents=True, exist_ok=True)

    cask_file = output_dir / f"{kebab_case(args.name)}.rb"

    dmgs = ((ARM_TARGET, args.arm_url), (INTEL_TARGET, args.intel_url))
    for target, url in dmgs:
        error = check_dmg_url(url, args.version, target, args.name)
        if error:
            print(f"error: {error}", file=sys.stderr)
            return 1

    sha256s: dict[str, str] = {}
    for target, url in dmgs:
        print(f"Downloading {target} DMG from {url}...")
        artifact_path = download_file(url)
        try:
            sha256s[target] = hash_file(artifact_path)
            if sys.platform == "darwin" and not args.skip_verify:
                verify_macos_artifact(
                    artifact_path,
                    args.app_name,
                    args.binary_name,
                    EXPECTED_MACHO_ARCH[target],
                    args.version,
                )
        finally:
            try:
                artifact_path.unlink()
            except OSError:
                pass

    contents = render_cask(
        cask_name=args.name,
        version=args.version,
        arm_sha256=sha256s[ARM_TARGET],
        intel_sha256=sha256s[INTEL_TARGET],
        app_name=args.app_name,
        app_target=app_target,
        binary_name=args.binary_name,
        binary_target=binary_target,
        desc=desc,
        homepage=args.homepage,
        clear_quarantine=args.allow_quarantine_clear,
    )

    cask_file.write_text(contents)
    print(f"Wrote cask to {cask_file}")
    for target, _ in dmgs:
        print(f"SHA256 ({target}): {sha256s[target]}")

    return 0


if __name__ == "__main__":
    sys.exit(main())
