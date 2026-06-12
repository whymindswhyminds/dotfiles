#!/usr/bin/env bash
# Runs once on each new machine — installs nvim stable binary on Linux VMs.
command -v nvim &>/dev/null && exit 0
[[ "$(uname -s)" == "Darwin" ]] && exit 0

# Ensure git, curl, and tree-sitter build deps are present
if command -v apt-get &>/dev/null; then
    sudo apt-get update -qq && sudo apt-get install -y git curl gcc make g++
elif command -v dnf &>/dev/null; then
    sudo dnf install -y git curl gcc make gcc-c++
elif command -v yum &>/dev/null; then
    sudo yum install -y git curl gcc make gcc-c++
fi

ARCH=$(uname -m)
if [[ "$ARCH" == "x86_64" ]]; then
    ASSET="nvim-linux-x86_64.tar.gz"
elif [[ "$ARCH" == "aarch64" ]]; then
    ASSET="nvim-linux-arm64.tar.gz"
else
    echo "Unsupported arch: $ARCH" && exit 1
fi

curl -LO "https://github.com/neovim/neovim/releases/download/stable/${ASSET}"
sudo tar -C /usr/local -xzf "$ASSET"
sudo ln -sf "/usr/local/${ASSET%.tar.gz}/bin/nvim" /usr/local/bin/nvim
rm -f "$ASSET"

echo "nvim installed: $(nvim --version | head -1)"
