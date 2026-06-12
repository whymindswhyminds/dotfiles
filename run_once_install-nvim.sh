#!/usr/bin/env bash
# Runs once on each new machine — installs nvim and all dependencies.
[[ "$(uname -s)" == "Darwin" ]] && exit 0

# ── Package installer ────────────────────────────────────────────────────────
install_pkgs() {
    if command -v apt-get &>/dev/null; then
        sudo apt-get update -qq && sudo apt-get install -y "$@"
    elif command -v dnf &>/dev/null; then
        sudo dnf install -y "$@"
    elif command -v yum &>/dev/null; then
        sudo yum install -y "$@"
    fi
}

# ── Core build tools + CLI utilities ────────────────────────────────────────
if command -v apt-get &>/dev/null; then
    install_pkgs git curl wget unzip tar \
        gcc make g++ \
        ripgrep fd-find \
        python3 python3-pip \
        nodejs npm
elif command -v dnf &>/dev/null || command -v yum &>/dev/null; then
    install_pkgs git curl wget unzip tar \
        gcc make gcc-c++ \
        ripgrep fd-find \
        python3 python3-pip \
        nodejs npm
fi

# fd is named fdfind on Ubuntu/Debian — symlink to fd
if command -v fdfind &>/dev/null && ! command -v fd &>/dev/null; then
    sudo ln -sf "$(which fdfind)" /usr/local/bin/fd
fi

# ── tree-sitter CLI (required by nvim 0.12+ to build parsers) ───────────────
if ! command -v tree-sitter &>/dev/null; then
    npm install -g tree-sitter-cli
fi

# ── Python debug adapter (nvim-dap) ─────────────────────────────────────────
pip3 install --quiet debugpy 2>/dev/null || true

# ── lazygit ──────────────────────────────────────────────────────────────────
if ! command -v lazygit &>/dev/null; then
    LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" \
        | grep -Po '"tag_name": "v\K[^"]*')
    ARCH=$(uname -m)
    [[ "$ARCH" == "aarch64" ]] && LG_ARCH="arm64" || LG_ARCH="x86_64"
    curl -Lo /tmp/lazygit.tar.gz \
        "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_${LG_ARCH}.tar.gz"
    sudo tar -C /usr/local/bin -xzf /tmp/lazygit.tar.gz lazygit
    rm -f /tmp/lazygit.tar.gz
    echo "lazygit installed: $(lazygit --version | head -1)"
fi

# ── Neovim stable binary ─────────────────────────────────────────────────────
if ! command -v nvim &>/dev/null; then
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
fi
