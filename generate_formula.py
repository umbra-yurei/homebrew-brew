#!/usr/bin/env python3
"""
Utility script to generate a Homebrew formula for a downloadable binary.

Single-URL (macOS) mode:
    python generate_formula.py \\
        --name cruma \\
        --version 0.3.0-beta.3 \\
        --url https://files.cruma.io/.../cruma \\
        --desc "Cruma tunnel agent" \\
        --homepage https://cruma.io \\
        --binary-name cruma \\
        --ad-hoc-sign

Linux multi-arch mode (generates on_arm / on_intel blocks, no ad-hoc signing):
    python generate_formula.py \\
        --name cruma \\
        --version 0.3.0-beta.3 \\
        --linux-arm-url https://files.cruma.io/.../aarch64-unknown-linux-gnu/cruma \\
        --linux-x86-url https://files.cruma.io/.../x86_64-unknown-linux-gnu/cruma \\
        --desc "Cruma tunnel agent" \\
        --homepage https://cruma.io \\
        --binary-name cruma
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


def class_name(name: str) -> str:
    tokens = re.split(r"[-_\s]+", name.strip())
    pretty = "".join(token.capitalize() for token in tokens if token)
    if not pretty:
        raise ValueError("Formula name must contain at least one alphanumeric character")
    return pretty


def download_file(url: str) -> pathlib.Path:
    tmp_fd, tmp_path = tempfile.mkstemp(prefix="formula-asset-")
    os.close(tmp_fd)
    with urllib.request.urlopen(url) as response, open(tmp_path, "wb") as tmp_file:
        while True:
            chunk = response.read(8192)
            if not chunk:
                break
            tmp_file.write(chunk)
    return pathlib.Path(tmp_path)


def hash_file(path: pathlib.Path) -> tuple[str, str]:
    sha256 = hashlib.sha256()
    md5 = hashlib.md5()
    with path.open("rb") as infile:
        for block in iter(lambda: infile.read(8192), b""):
            sha256.update(block)
            md5.update(block)
    return sha256.hexdigest(), md5.hexdigest()


def render_formula(
    class_name_str: str,
    desc: str,
    homepage: str,
    version: str,
    url: str,
    sha256: str,
    binary_name: str,
    binary_target: str,
    nounzip: bool,
    ad_hoc_sign: bool,
) -> str:
    nounzip_clause = ",\n      using: :nounzip" if nounzip else ""
    install_clause = f'"{binary_name}"'
    if binary_target != binary_name:
        install_clause = f'"{binary_name}" => "{binary_target}"'
    post_install_section = ""
    if ad_hoc_sign:
        post_install_section = f"""
  def post_install
    system "/bin/chmod", "755", bin/"{binary_target}"
    system "/usr/bin/xattr", "-drs", "com.apple.quarantine", bin/"{binary_target}"
    system "/usr/bin/codesign", "--force", "--deep", "-s", "-", bin/"{binary_target}"
  end
"""

    formula = f"""class {class_name_str} < Formula
  desc "{desc}"
  homepage "{homepage}"
  version "{version}"

  url "{url}"{nounzip_clause}
  sha256 "{sha256}"

  def install
    bin.install {install_clause}
  end
{post_install_section}
  test do
    assert_match "{binary_name.split()[0]}", shell_output("#{{bin}}/{binary_target} --version")
  end
end
"""
    return "\n".join(line.rstrip() for line in formula.strip("\n").splitlines()) + "\n"


def render_linux_formula(
    class_name_str: str,
    desc: str,
    homepage: str,
    version: str,
    arm_url: str,
    arm_sha256: str,
    x86_url: str,
    x86_sha256: str,
    binary_name: str,
    binary_target: str,
) -> str:
    install_clause = f'"{binary_name}"'
    if binary_target != binary_name:
        install_clause = f'"{binary_name}" => "{binary_target}"'
    formula = f"""class {class_name_str} < Formula
  desc "{desc}"
  homepage "{homepage}"
  version "{version}"

  on_linux do
    on_arm do
      url "{arm_url}"
      sha256 "{arm_sha256}"
    end
    on_intel do
      url "{x86_url}"
      sha256 "{x86_sha256}"
    end
  end

  def install
    bin.install {install_clause}
  end

  def post_install
    system "/bin/chmod", "755", bin/"{binary_target}"
  end

  test do
    assert_match "{binary_name.split()[0]}", shell_output("#{{bin}}/{binary_target} --version")
  end
end
"""
    return "\n".join(line.rstrip() for line in formula.strip("\n").splitlines()) + "\n"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Generate a Homebrew formula for a binary artifact.")
    parser.add_argument("--name", required=True, help="Formula name (e.g. cruma)")
    parser.add_argument("--version", required=True, help="Semantic version or git tag")
    parser.add_argument("--desc", default="", help="One-line description for the formula")
    parser.add_argument("--homepage", default="https://example.com", help="Project homepage URL")
    parser.add_argument(
        "--binary-name",
        help="Name of the binary inside the download (defaults to the formula name)",
    )
    parser.add_argument(
        "--binary-target",
        help="Installed binary name inside Homebrew's bin/ (defaults to --binary-name)",
    )
    parser.add_argument(
        "--output-dir",
        default="Formula",
        help="Directory where the formula file should be written (default: Formula)",
    )

    # Single-URL mode
    parser.add_argument("--url", help="Download URL for a single-arch binary")
    parser.add_argument(
        "--nounzip",
        action="store_true",
        help="Include `using: :nounzip` so Homebrew installs raw binaries",
    )
    parser.add_argument(
        "--ad-hoc-sign",
        dest="ad_hoc_sign",
        action="store_true",
        help="Add a post_install hook that clears quarantine and ad-hoc signs the binary",
    )
    parser.add_argument(
        "--no-ad-hoc-sign",
        dest="ad_hoc_sign",
        action="store_false",
        help="Skip the post_install hook (default for Linux)",
    )
    parser.set_defaults(ad_hoc_sign=True)

    # Linux multi-arch mode
    parser.add_argument("--linux-arm-url", help="URL for the aarch64 Linux binary")
    parser.add_argument("--linux-x86-url", help="URL for the x86_64 Linux binary")

    return parser.parse_args()


def main() -> int:
    args = parse_args()
    bin_name = args.binary_name or args.name
    bin_target = args.binary_target or bin_name
    desc = args.desc or f"{args.name} CLI"
    formula_class = class_name(args.name)

    base_dir = pathlib.Path(__file__).resolve().parent
    output_dir = pathlib.Path(args.output_dir)
    if not output_dir.is_absolute():
        output_dir = (base_dir / output_dir).resolve()
    output_dir.mkdir(parents=True, exist_ok=True)

    formula_file = output_dir / f"{kebab_case(args.name)}.rb"

    linux_mode = bool(args.linux_arm_url or args.linux_x86_url)

    if linux_mode:
        if not args.linux_arm_url or not args.linux_x86_url:
            print("Error: --linux-arm-url and --linux-x86-url must both be provided.", file=sys.stderr)
            return 1

        print(f"Downloading Linux arm64 artifact from {args.linux_arm_url}...")
        arm_path = download_file(args.linux_arm_url)
        arm_sha256, _ = hash_file(arm_path)

        print(f"Downloading Linux x86_64 artifact from {args.linux_x86_url}...")
        x86_path = download_file(args.linux_x86_url)
        x86_sha256, _ = hash_file(x86_path)

        contents = render_linux_formula(
            formula_class, desc, args.homepage, args.version,
            args.linux_arm_url, arm_sha256,
            args.linux_x86_url, x86_sha256,
            bin_name, bin_target,
        )

        formula_file.write_text(contents)
        print(f"Wrote formula to {formula_file}")
        print(f"SHA256 (arm64): {arm_sha256}")
        print(f"SHA256 (x86_64): {x86_sha256}")

        for p in (arm_path, x86_path):
            try:
                p.unlink()
            except OSError:
                pass
    else:
        if not args.url:
            print("Error: --url is required in single-URL mode.", file=sys.stderr)
            return 1

        print(f"Downloading artifact from {args.url}...")
        artifact_path = download_file(args.url)
        sha256_hash, md5_hash = hash_file(artifact_path)

        contents = render_formula(
            formula_class, desc, args.homepage, args.version,
            args.url, sha256_hash, bin_name, bin_target,
            nounzip=args.nounzip,
            ad_hoc_sign=args.ad_hoc_sign,
        )

        formula_file.write_text(contents)
        print(f"Wrote formula to {formula_file}")
        print(f"SHA256: {sha256_hash}")
        print(f"MD5:    {md5_hash}")

        try:
            artifact_path.unlink()
        except OSError:
            pass

    return 0


if __name__ == "__main__":
    sys.exit(main())
