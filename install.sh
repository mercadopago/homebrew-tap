#!/bin/sh
# Install mp CLI — the official Mercado Pago command-line interface.
#
# Usage (curl):
#   curl -fsSL https://raw.githubusercontent.com/mercadopago/homebrew-tap/main/install.sh | sh
#
# Usage (wget):
#   wget -qO- https://raw.githubusercontent.com/mercadopago/homebrew-tap/main/install.sh | sh
set -e

REPO="mercadopago/homebrew-tap"
BINARY="mpcli"
INSTALL_DIR="/usr/local/bin"

# ── OS detection ──────────────────────────────────────────────────────────────
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
case "$OS" in
  darwin) OS="darwin" ;;
  linux)  OS="linux"  ;;
  *)
    echo "Unsupported OS: $OS"
    echo "Download manually from: https://github.com/${REPO}/releases"
    exit 1
    ;;
esac

# ── Architecture detection ────────────────────────────────────────────────────
ARCH=$(uname -m)
case "$ARCH" in
  x86_64 | amd64)  ARCH="amd64" ;;
  arm64 | aarch64) ARCH="arm64" ;;
  *)
    echo "Unsupported architecture: $ARCH"
    echo "Download manually from: https://github.com/${REPO}/releases"
    exit 1
    ;;
esac

# ── Fetch latest version ──────────────────────────────────────────────────────
echo "Fetching latest release..."

if command -v curl >/dev/null 2>&1; then
  VERSION=$(curl -sf "https://api.github.com/repos/${REPO}/releases/latest" \
    | grep '"tag_name"' \
    | sed 's/.*"tag_name": *"\(.*\)".*/\1/')
elif command -v wget >/dev/null 2>&1; then
  VERSION=$(wget -qO- "https://api.github.com/repos/${REPO}/releases/latest" \
    | grep '"tag_name"' \
    | sed 's/.*"tag_name": *"\(.*\)".*/\1/')
else
  echo "Error: curl or wget is required."
  exit 1
fi

if [ -z "$VERSION" ]; then
  echo "Error: could not fetch latest release from ${REPO}."
  exit 1
fi

ASSET="mp_${VERSION#v}_${OS}_${ARCH}.tar.gz"
DOWNLOAD_URL="https://github.com/${REPO}/releases/download/${VERSION}/${ASSET}"

echo "Installing mpcli ${VERSION} (${OS}/${ARCH})..."

# ── Download & install ────────────────────────────────────────────────────────
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

if command -v curl >/dev/null 2>&1; then
  curl -sfL "$DOWNLOAD_URL" | tar -xz -C "$TMP"
else
  wget -qO- "$DOWNLOAD_URL" | tar -xz -C "$TMP"
fi

sudo mv "$TMP/$BINARY" "$INSTALL_DIR/$BINARY"
sudo chmod +x "$INSTALL_DIR/$BINARY"

echo ""
echo "mpcli ${VERSION} installed to ${INSTALL_DIR}/${BINARY}"
echo ""
mpcli --version
