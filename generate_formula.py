#!/usr/bin/env python3
"""
Utility script to generate a Homebrew formula for a single downloadable binary.

Example:
    python generate_formula.py \\
        --name cruma-tunnel \\
        --version 0.3.0-alpha.10 \\
        --url https://files.cruma.io/path/to/binary \\
        --desc "Cruma tunnel agent" \\
        --homepage https://cruma.io \\
        --binary-name cruma \\
        --nounzip \\
        --ad-hoc-sign
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
    """Convert arbitrary name into a filesystem-friendly kebab-case string."""
    tokens = re.split(r"[\s_]+", name.strip().lower())
    return "-".join(filter(None, tokens))


def class_name(name: str) -> str:
    """Transform a CLI name like 'cruma' into a Homebrew formula class name."""
    tokens = re.split(r"[-_\s]+", name.strip())
    pretty = "".join(token.capitalize() for token in tokens if token)
    if not pretty:
        raise ValueError("Formula name must contain at least one alphanumeric character")
    return pretty


def download_file(url: str) -> pathlib.Path:
    """Download the artifact at `url` into a temporary file and return its path."""
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
    """Return the (sha256, md5) for `path`."""
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
    nounzip: bool,
    ad_hoc_sign: bool,
) -> str:
    """Render the Ruby formula string from the collected metadata."""
    nounzip_clause = ",\n      using: :nounzip" if nounzip else ""
    post_install_block = ""
    if ad_hoc_sign:
        post_install_block = f"""
  def post_install
    system "/bin/chmod", "755", bin/"{binary_name}"
    system "/usr/bin/xattr", "-drs", "com.apple.quarantine", bin/"{binary_name}"
    system "/usr/bin/codesign", "--force", "--deep", "-s", "-", bin/"{binary_name}"
  end
"""

    post_install_section = ""
    if post_install_block:
        post_install_section = f"{post_install_block.strip(chr(10))}\n\n"

    formula = f"""class {class_name_str} < Formula
  desc "{desc}"
  homepage "{homepage}"
  version "{version}"

  url "{url}"{nounzip_clause}
  sha256 "{sha256}"

  def install
    bin.install "{binary_name}"
  end
{post_install_section}  test do
    assert_match "{binary_name.split()[0]}", shell_output("#{{bin}}/{binary_name} --version")
  end
end
"""
    return "\n".join(line.rstrip() for line in formula.strip("\n").splitlines()) + "\n"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Generate a Homebrew formula for a binary artifact.")
    parser.add_argument("--name", required=True, help="Formula name (e.g. cruma)")
    parser.add_argument("--version", required=True, help="Semantic version or git tag")
    parser.add_argument("--url", required=True, help="Download URL to the binary artifact")
    parser.add_argument("--desc", default="", help="One-line description for the formula")
    parser.add_argument("--homepage", default="https://example.com", help="Project homepage URL")
    parser.add_argument(
        "--binary-name",
        help="Name of the binary inside the download (defaults to the formula name)",
    )
    parser.add_argument(
        "--output-dir",
        default="Formula",
        help="Directory where the formula file should be written (default: Formula)",
    )
    parser.add_argument(
        "--nounzip",
        action="store_true",
        help="Include `using: :nounzip` so Homebrew installs raw binaries",
    )
    parser.add_argument(
        "--ad-hoc-sign",
        dest="ad_hoc_sign",
        action="store_true",
        help="(default) Add a post_install hook that clears quarantine and ad-hoc signs the binary",
    )
    parser.add_argument(
        "--no-ad-hoc-sign",
        dest="ad_hoc_sign",
        action="store_false",
        help="Skip the post_install hook that clears quarantine and ad-hoc signs the binary",
    )
    parser.set_defaults(ad_hoc_sign=True)
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    bin_name = args.binary_name or args.name

    base_dir = pathlib.Path(__file__).resolve().parent

    formula_class = class_name(args.name)
    output_dir = pathlib.Path(args.output_dir)
    if not output_dir.is_absolute():
        output_dir = (base_dir / output_dir).resolve()

    formula_file = output_dir / f"{kebab_case(args.name)}.rb"
    formula_file.parent.mkdir(parents=True, exist_ok=True)

    print(f"Downloading artifact from {args.url}...")
    artifact_path = download_file(args.url)
    sha256_hash, md5_hash = hash_file(artifact_path)

    desc = args.desc or f"{args.name} CLI"

    formula_contents = render_formula(
        formula_class,
        desc,
        args.homepage,
        args.version,
        args.url,
        sha256_hash,
        bin_name,
        nounzip=args.nounzip,
        ad_hoc_sign=args.ad_hoc_sign,
    )

    formula_file.write_text(formula_contents)
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
