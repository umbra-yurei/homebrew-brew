#!/usr/bin/env python3
"""
Utility script to generate a Homebrew cask for a macOS .app distributed as a DMG.

Example:
    python generate_cask.py \\
        --name cruma \\
        --version 0.3.0-beta.3 \\
        --url https://files.cruma.io/.../cruma.dmg \\
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
import re
import sys
import tempfile
import urllib.request


def kebab_case(name: str) -> str:
    tokens = re.split(r"[\s_]+", name.strip().lower())
    return "-".join(filter(None, tokens))


def download_file(url: str) -> pathlib.Path:
    tmp_fd, tmp_path = tempfile.mkstemp(prefix="cask-asset-")
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


def render_cask(
    cask_name: str,
    version: str,
    url: str,
    sha256: str,
    app_name: str,
    app_target: str,
    binary_name: str,
    binary_target: str,
    desc: str,
    homepage: str,
) -> str:
    installed_app_name = app_target or app_name
    binary_path = f"#{{appdir}}/{installed_app_name}/Contents/MacOS/{binary_name}"
    app_clause = f'app "{app_name}"'
    if installed_app_name != app_name:
        app_clause = f'app "{app_name}", target: "{installed_app_name}"'
    binary_clause = f'binary "{binary_path}"'
    if binary_target != binary_name:
        binary_clause = f'binary "{binary_path}", target: "{binary_target}"'

    cask = f"""cask "{cask_name}" do
  version "{version}"

  url "{url}"
  sha256 "{sha256}"

  name "{installed_app_name.removesuffix('.app')}"
  desc "{desc}"
  homepage "{homepage}"

  {app_clause}

  # Symlinks the binary into $(brew --prefix)/bin so `{binary_target}` works in the terminal
  {binary_clause}

  postflight do
    system_command "/usr/bin/xattr",
                   args: ["-drs", "com.apple.quarantine", "#{{appdir}}/{installed_app_name}"]
    system_command "/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister",
                   args: ["-f", "#{{appdir}}/{installed_app_name}"]
    system_command "/usr/bin/mdimport",
                   args: ["#{{appdir}}/{installed_app_name}"]
  end
end
"""
    return "\n".join(line.rstrip() for line in cask.strip("\n").splitlines()) + "\n"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Generate a Homebrew cask for a macOS DMG.")
    parser.add_argument("--name", required=True, help="Cask name (e.g. cruma)")
    parser.add_argument("--version", required=True, help="Semantic version string")
    parser.add_argument("--url", required=True, help="Download URL for the DMG")
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

    print(f"Downloading DMG from {args.url}...")
    artifact_path = download_file(args.url)
    sha256 = hash_file(artifact_path)

    contents = render_cask(
        cask_name=args.name,
        version=args.version,
        url=args.url,
        sha256=sha256,
        app_name=args.app_name,
        app_target=app_target,
        binary_name=args.binary_name,
        binary_target=binary_target,
        desc=desc,
        homepage=args.homepage,
    )

    cask_file.write_text(contents)
    print(f"Wrote cask to {cask_file}")
    print(f"SHA256: {sha256}")

    try:
        artifact_path.unlink()
    except OSError:
        pass

    return 0


if __name__ == "__main__":
    sys.exit(main())
