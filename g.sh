#!/usr/bin/env bash
set -euo pipefail

# Generates the Homebrew formula (Linux) and/or cask (macOS) for a given version.
# Artifacts must already be uploaded to files.cruma.io before running this.
#
# Usage: ./g.sh <version> [--preview] [--os macos|linux|all]
# Example: ./g.sh 0.3.0-beta.3 --preview --os macos

usage() {
    cat <<'EOF'
Usage: ./g.sh <version> [--preview] [--os macos|linux|all]

Options:
  --preview      Generate preview artifacts as cruma-preview
  --os <value>   Limit output to macos, linux, or all (default: all)
  --help         Show this help text
EOF
}

if [[ $# -eq 0 ]]; then
    echo "Usage: ./g.sh <version> [--preview] [--os macos|linux|all]" >&2
    exit 1
fi

if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    usage
    exit 0
fi

VERSION="$1"
shift

PREVIEW=false
GENERATE_MACOS=true
GENERATE_LINUX=true

set_os_selection() {
    case "$1" in
        macos|darwin|cask)
            GENERATE_MACOS=true
            GENERATE_LINUX=false
            ;;
        linux|formula)
            GENERATE_MACOS=false
            GENERATE_LINUX=true
            ;;
        all)
            GENERATE_MACOS=true
            GENERATE_LINUX=true
            ;;
        *)
            echo "error: unsupported --os value '$1'" >&2
            usage >&2
            exit 1
            ;;
    esac
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --preview)
            PREVIEW=true
            shift
            ;;
        --os)
            [[ $# -ge 2 ]] || {
                echo "error: --os requires a value" >&2
                usage >&2
                exit 1
            }
            set_os_selection "$2"
            shift 2
            ;;
        --help|-h)
            usage
            exit 0
            ;;
        *)
            echo "error: unknown argument '$1'" >&2
            usage >&2
            exit 1
            ;;
    esac
done

if [[ "${PREVIEW}" == true ]]; then
    NAME="cruma-preview"
    DESC="Cruma tunnel agent (preview)"
    FORMULA_BINARY_TARGET="cruma-preview"
    CASK_APP_TARGET="Cruma Preview.app"
    CASK_BINARY_TARGET="cruma-preview"
    CHANNEL_SUFFIX=" (preview)"
else
    NAME="cruma"
    DESC="Cruma tunnel agent"
    FORMULA_BINARY_TARGET="cruma"
    CASK_APP_TARGET="Cruma.app"
    CASK_BINARY_TARGET="cruma"
    CHANNEL_SUFFIX=""
fi

BASE_URL="https://files.cruma.io/files/tunnel-agent/v${VERSION}"

if [[ "${GENERATE_MACOS}" == true && "${GENERATE_LINUX}" == true ]]; then
    TARGET_LABEL="formula + cask"
elif [[ "${GENERATE_MACOS}" == true ]]; then
    TARGET_LABEL="cask only"
else
    TARGET_LABEL="formula only"
fi

echo "==> Generating Homebrew ${TARGET_LABEL} for v${VERSION}${CHANNEL_SUFFIX}"
echo "    Base URL: ${BASE_URL}"
echo ""

if [[ "${GENERATE_LINUX}" == true ]]; then
    echo "[linux] Generating Formula/${NAME}.rb..."
    python3 generate_formula.py \
        --name "${NAME}" \
        --version "${VERSION}" \
        --linux-arm-url "${BASE_URL}/aarch64-unknown-linux-musl/cruma" \
        --linux-x86-url "${BASE_URL}/x86_64-unknown-linux-musl/cruma" \
        --desc "${DESC}" \
        --homepage "https://cruma.io" \
        --binary-name "cruma" \
        --binary-target "${FORMULA_BINARY_TARGET}" \
        --no-ad-hoc-sign
fi

if [[ "${GENERATE_MACOS}" == true ]]; then
    echo ""
    echo "[macos] Generating Casks/${NAME}.rb..."
    python3 generate_cask.py \
        --name "${NAME}" \
        --version "${VERSION}" \
        --url "${BASE_URL}/aarch64-apple-darwin/cruma.dmg" \
        --app-name "Cruma.app" \
        --app-target "${CASK_APP_TARGET}" \
        --binary-name "cruma" \
        --binary-target "${CASK_BINARY_TARGET}" \
        --desc "${DESC}" \
        --homepage "https://cruma.io"
fi

if [[ "${PREVIEW}" == false && "${GENERATE_LINUX}" == true && -f "Formula/cruma-tunnel.rb" ]]; then
    echo ""
    echo "Removing old Formula/cruma-tunnel.rb..."
    rm "Formula/cruma-tunnel.rb"
fi

echo ""
echo "==> Done. Review and commit:"
if [[ "${GENERATE_LINUX}" == true ]]; then
    echo "    Formula/${NAME}.rb"
fi
if [[ "${GENERATE_MACOS}" == true ]]; then
    echo "    Casks/${NAME}.rb"
fi
