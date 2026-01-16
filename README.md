# Umbra Yurei Homebrew Tap

This repository hosts the `umbra-yurei/brew` tap for distributing Umbra Yurei CLI binaries through Homebrew. Use this tap to install prerelease or custom tooling that is not available in the core Homebrew repositories.

## Usage

Add the tap and install the `cruma-tunnel` formula:

```bash
brew tap umbra-yurei/brew
brew install umbra-yurei/brew/cruma-tunnel
```

## Repository Layout

- `Formula/` contains Ruby formula definitions for each distributed tool.
- `README.md` documents usage patterns and maintenance tips.

## Releasing Updates

1. Build the new binaries and upload them to the public file service (currently `files.cruma.io`).
2. Update the corresponding formula with the new version, architecture-specific download URLs, and SHA256 checksums.
3. Submit a PR or push changes directly to publish the release.

> **Note:** `cruma-tunnel` currently ships only a macOS Apple Silicon build located at  
> `https://files.cruma.io/files/tunnel-agent/v0.3.0-alpha.10/aarch64-apple-darwin/cruma-tunnel`. The formula
> clears the quarantine bit and re-signs the installed binary post-install so internal users can run unsigned
> development builds without manual intervention.

## Generating Formulas

Use `generate_formula.py` to scaffold new formulas from binary downloads. The script fetches the
artifact, computes both SHA256 and MD5 hashes, and writes a ready-to-tweak Ruby formula.

```bash
python generate_formula.py \
  --name cruma-tunnel \
  --version 0.3.0-alpha.10 \
  --url https://files.cruma.io/files/tunnel-agent/v0.3.0-alpha.10/aarch64-apple-darwin/cruma-tunnel \
  --desc "Cruma tunnel agent for exposing local services securely" \
  --homepage https://cruma.io \
  --binary-name cruma-tunnel \
  --nounzip \
  --ad-hoc-sign
```

After the script runs, inspect the generated file in `Formula/`, make any manual tweaks (e.g., platform guards),
then commit and push.
