#!/usr/bin/env bash
set -euo pipefail

PKG_DIR="$(cd "$(dirname "$0")/.." && pwd)"

if ! command -v sui >/dev/null 2>&1; then
  echo "Error: 'sui' CLI not found. Please install Sui CLI first." >&2
  echo "Install (Linux): curl -fsSL https://install.sui.io | sh" >&2
  exit 127
fi

pushd "$PKG_DIR" >/dev/null

echo "Configuring Sui client env: devnet"
sui client new-env --alias devnet --rpc https://fullnode.devnet.sui.io:443 || true
sui client switch --env devnet

echo "Active address: $(sui client active-address || true)"
echo "Building package..."
sui move build

echo "Publishing to devnet..."
set -x
sui client publish --gas-budget 100000000
set +x

popd >/dev/null
echo "Done."
