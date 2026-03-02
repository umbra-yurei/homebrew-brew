#!/usr/bin/env bash
set -euo pipefail

# Tests the cruma cask locally without needing to upload to files.cruma.io.
# Creates a temporary tap so Homebrew 5.0+ accepts the cask.
#
# Usage:
#   ./test-cask-local.sh                          # looks for DMG in ../cruma-sdk/release-v*/
#   ./test-cask-local.sh /path/to/cruma.dmg       # explicit DMG path
#
# To uninstall afterwards:
#   ./test-cask-local.sh --uninstall

TEMP_TAP_USER="cruma-local-test"
TEMP_TAP_REPO="homebrew-cruma-local-test"
TEMP_TAP_NAME="${TEMP_TAP_USER}/${TEMP_TAP_REPO#homebrew-}"
TEMP_TAP_DIR="$(brew --repository)/Library/Taps/${TEMP_TAP_USER}/${TEMP_TAP_REPO}"

# ── Uninstall mode ────────────────────────────────────────────────────────────
if [[ "${1:-}" == "--uninstall" ]]; then
    echo "Uninstalling..."
    brew uninstall --cask --force cruma 2>/dev/null || true
    brew untap "${TEMP_TAP_NAME}" 2>/dev/null || true
    echo "Done."
    exit 0
fi

# ── Locate DMG ────────────────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

if [[ -n "${1:-}" ]]; then
    DMG_PATH="$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
else
    DMG_PATH="$(find "${SCRIPT_DIR}/../cruma-sdk" -name "cruma.dmg" -path "*/aarch64-apple-darwin/*" 2>/dev/null | sort | tail -1)"
fi

if [[ -z "${DMG_PATH}" || ! -f "${DMG_PATH}" ]]; then
    echo "Error: could not find cruma.dmg"
    echo "Run build-release-artifacts.sh (or pack-osx.sh) first, or pass the path explicitly."
    exit 1
fi

echo "Using DMG: ${DMG_PATH}"

# ── Compute SHA256 ────────────────────────────────────────────────────────────
SHA256="$(shasum -a 256 "${DMG_PATH}" | awk '{print $1}')"
echo "SHA256:    ${SHA256}"

# ── Create temporary tap ──────────────────────────────────────────────────────
mkdir -p "${TEMP_TAP_DIR}/Casks"

cat > "${TEMP_TAP_DIR}/Casks/cruma.rb" <<RUBY
cask "cruma" do
  version "local"

  url "file://${DMG_PATH}"
  sha256 "${SHA256}"

  name "Cruma"
  desc "Cruma tunnel agent (local test)"
  homepage "https://cruma.io"

  app "Cruma.app"
  binary "Cruma.app/Contents/MacOS/cruma"

  postflight do
    system_command "/usr/bin/xattr",
                   args: ["-drs", "com.apple.quarantine", "#{appdir}/Cruma.app"]
    system_command "/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister",
                   args: ["-f", "#{appdir}/Cruma.app"]
    system_command "/usr/bin/mdimport",
                   args: ["#{appdir}/Cruma.app"]
  end
end
RUBY

brew tap "${TEMP_TAP_NAME}" "${TEMP_TAP_DIR}" 2>/dev/null || true

# ── Install ───────────────────────────────────────────────────────────────────
echo ""
echo "Installing cask from temporary tap..."
brew uninstall --cask --force cruma 2>/dev/null || true

# Remove old conflicting formula if present
if brew list --formula cruma-tunnel &>/dev/null; then
    echo "Uninstalling old cruma-tunnel formula..."
    brew uninstall --formula cruma-tunnel
fi

# Clear any stale cached DMG — hash will differ between builds
rm -f "$(brew --cache)/downloads/"*--cruma.dmg

brew install --cask "${TEMP_TAP_NAME}/cruma"

# ── Run registration directly (postflight may run in restricted context) ──────
echo ""
echo "Running post-install registration directly..."
xattr -drs com.apple.quarantine /Applications/Cruma.app 2>/dev/null || true

/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister \
    -f /Applications/Cruma.app

echo "Forcing Spotlight import..."
/usr/bin/mdimport -f /Applications/Cruma.app 2>&1 || true

echo ""
echo "Test import output (what Spotlight sees in the bundle):"
/usr/bin/mdimport -t -d2 /Applications/Cruma.app 2>&1 || true

echo ""
echo "Spotlight metadata after import:"
mdls /Applications/Cruma.app 2>&1 | head -20 || true

# ── Smoke test ────────────────────────────────────────────────────────────────
echo ""
echo "Testing CLI..."
if cruma --version; then
    echo ""
    echo "==> Cask install OK — app and CLI both work."
    echo "    To uninstall: ./test-cask-local.sh --uninstall"
else
    echo "Error: 'cruma --version' failed after install."
    exit 1
fi
