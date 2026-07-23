#!/usr/bin/env bash
# setup-kiro-devcontainers.sh
# Downloads and installs the VS Code Dev Containers extension into Kiro IDE.
#
# The Dev Containers extension is proprietary (Microsoft) and not available on
# Open VSX. This script sideloads the VSIX and configures the required
# proposed API access in Kiro IDE's argv.json.
#
# Prerequisites:
#   - Kiro IDE installed (the `kiro` command must be on PATH)
#   - curl available
#
# Usage:
#   ./scripts/setup-kiro-devcontainers.sh
#
# After running, restart Kiro IDE completely.

set -euo pipefail

EXTENSION_ID="ms-vscode-remote.remote-containers"
EXTENSION_VERSION=""  # Leave empty for latest
VSIX_DIR="${TMPDIR:-/tmp}/kiro-vsix"
ARGV_JSON="${HOME}/.kiro/argv.json"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info()  { echo -e "${GREEN}[INFO]${NC} $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*" >&2; }

# Detect platform for VSIX target
detect_platform() {
  local os arch
  os="$(uname -s)"
  arch="$(uname -m)"

  case "$os" in
    Darwin)
      case "$arch" in
        arm64) echo "darwin-arm64" ;;
        x86_64) echo "darwin-x64" ;;
        *) echo "universal" ;;
      esac
      ;;
    Linux)
      case "$arch" in
        x86_64) echo "linux-x64" ;;
        aarch64) echo "linux-arm64" ;;
        armv7l) echo "linux-armhf" ;;
        *) echo "universal" ;;
      esac
      ;;
    MINGW*|MSYS*|CYGWIN*)
      case "$arch" in
        x86_64) echo "win32-x64" ;;
        aarch64) echo "win32-arm64" ;;
        *) echo "universal" ;;
      esac
      ;;
    *) echo "universal" ;;
  esac
}

# Download the VSIX from VS Code Marketplace
download_vsix() {
  local platform="$1"
  local publisher="${EXTENSION_ID%%.*}"
  local name="${EXTENSION_ID#*.}"

  mkdir -p "$VSIX_DIR"

  # Construct download URL
  # Format: https://marketplace.visualstudio.com/_apis/public/gallery/publishers/{publisher}/vsextensions/{name}/{version}/vspackage?targetPlatform={platform}
  local base_url="https://${publisher}.gallery.vsassets.io/_apis/public/gallery/publisher/${publisher}/extension/${name}/latest/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage"

  if [ -n "$EXTENSION_VERSION" ]; then
    base_url="https://${publisher}.gallery.vsassets.io/_apis/public/gallery/publisher/${publisher}/extension/${name}/${EXTENSION_VERSION}/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage"
  fi

  local vsix_file="${VSIX_DIR}/${EXTENSION_ID}-${platform}.vsix"

  info "Downloading ${EXTENSION_ID} for ${platform}..."
  info "URL: ${base_url}"

  if curl -fSL -o "$vsix_file" "${base_url}?targetPlatform=${platform}" 2>/dev/null; then
    echo "$vsix_file"
  elif curl -fSL -o "$vsix_file" "$base_url" 2>/dev/null; then
    # Fallback: try without platform (universal)
    echo "$vsix_file"
  else
    error "Failed to download VSIX. Try downloading manually from:"
    error "  https://marketplace.visualstudio.com/items?itemName=${EXTENSION_ID}"
    error "  (Click 'Download Extension' in the Resources sidebar)"
    return 1
  fi
}

# Install the VSIX into Kiro IDE
install_vsix() {
  local vsix_file="$1"

  if ! command -v kiro &>/dev/null; then
    error "Kiro IDE not found on PATH. Install from https://kiro.dev/downloads/"
    error "Alternatively, install manually:"
    error "  1. Open Kiro IDE"
    error "  2. Ctrl+Shift+P → 'Extensions: Install from VSIX...'"
    error "  3. Select: ${vsix_file}"
    return 1
  fi

  info "Installing extension into Kiro IDE..."
  kiro --install-extension "$vsix_file"
}

# Configure argv.json with enable-proposed-api
configure_argv() {
  info "Configuring proposed API access in ${ARGV_JSON}..."

  mkdir -p "$(dirname "$ARGV_JSON")"

  if [ ! -f "$ARGV_JSON" ]; then
    # Create fresh argv.json
    cat > "$ARGV_JSON" <<'EOF'
{
  "enable-proposed-api": [
    "ms-vscode-remote.remote-containers"
  ]
}
EOF
    info "Created ${ARGV_JSON}"
    return
  fi

  # Check if already configured
  if grep -q "ms-vscode-remote.remote-containers" "$ARGV_JSON" 2>/dev/null; then
    info "Already configured in argv.json — skipping."
    return
  fi

  # Attempt to add to existing file
  if command -v jq &>/dev/null; then
    local tmp="${ARGV_JSON}.tmp"
    jq '
      if .["enable-proposed-api"] then
        .["enable-proposed-api"] += ["ms-vscode-remote.remote-containers"]
      else
        . + {"enable-proposed-api": ["ms-vscode-remote.remote-containers"]}
      end
    ' "$ARGV_JSON" > "$tmp" && mv "$tmp" "$ARGV_JSON"
    info "Updated ${ARGV_JSON} via jq."
  else
    warn "jq not found. Please manually add to ${ARGV_JSON}:"
    warn ""
    warn '  "enable-proposed-api": ["ms-vscode-remote.remote-containers"]'
    warn ""
    warn "You can open it via: Preferences: Configure Runtime Arguments"
  fi
}

# Main
main() {
  echo ""
  echo "╔══════════════════════════════════════════════════════════════╗"
  echo "║  Kiro IDE — Dev Containers Extension Setup                  ║"
  echo "║                                                              ║"
  echo "║  This installs the proprietary VS Code Dev Containers       ║"
  echo "║  extension via VSIX sideloading and configures proposed     ║"
  echo "║  API access.                                                 ║"
  echo "╚══════════════════════════════════════════════════════════════╝"
  echo ""

  local platform
  platform="$(detect_platform)"
  info "Detected platform: ${platform}"

  # Step 1: Download
  local vsix_file
  vsix_file="$(download_vsix "$platform")" || {
    error "Download failed. See manual instructions above."
    exit 1
  }
  info "Downloaded: ${vsix_file}"

  # Step 2: Install
  install_vsix "$vsix_file" || {
    warn "Auto-install failed. Install manually from: ${vsix_file}"
  }

  # Step 3: Configure argv.json
  configure_argv

  # Step 4: Cleanup
  info "Cleaning up temporary files..."
  rm -rf "$VSIX_DIR"

  echo ""
  info "✅ Setup complete!"
  info ""
  info "Next steps:"
  info "  1. Restart Kiro IDE completely (close all windows)"
  info "  2. Open this repo folder in Kiro IDE"
  info "  3. You should see a 'Reopen in Container' prompt"
  info "  4. If not: Ctrl+Shift+P → 'Dev Containers: Reopen in Container'"
  echo ""
  warn "⚠️  After Kiro IDE updates, the Dev Containers extension may break."
  warn "   Re-run this script if that happens."
  echo ""
}

main "$@"
