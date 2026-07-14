#!/usr/bin/env bash
# setup-shell.sh — bootstrap zsh + oh-my-zsh (bira theme) on a fresh VPS
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/t7spotter/<my-zsh-setup/main/setup-shell.sh | bash
# or after cloning your dotfiles repo:
#   bash setup-shell.sh

set -euo pipefail

echo "==> Installing zsh, git, curl"
OS="$(uname -s)"
if [ "$OS" = "Darwin" ]; then
    if ! command -v brew >/dev/null 2>&1; then
        echo "==> Homebrew not found, installing it first"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        # Apple Silicon Macs need brew on PATH for the rest of this script
        if [ -x /opt/homebrew/bin/brew ]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
    fi
    brew install zsh git curl
elif command -v apt >/dev/null 2>&1; then
    # Debian, Ubuntu, Mint, Pop!_OS, etc.
    sudo apt update && sudo apt install -y zsh git curl
elif command -v dnf >/dev/null 2>&1; then
    # Fedora, RHEL 8+, Rocky, AlmaLinux
    sudo dnf install -y zsh git curl
elif command -v yum >/dev/null 2>&1; then
    # Older RHEL/CentOS
    sudo yum install -y zsh git curl
elif command -v pacman >/dev/null 2>&1; then
    # Arch, Manjaro
    sudo pacman -Sy --noconfirm zsh git curl
elif command -v zypper >/dev/null 2>&1; then
    # openSUSE
    sudo zypper --non-interactive install zsh git curl
elif command -v apk >/dev/null 2>&1; then
    # Alpine
    sudo apk add --no-cache zsh git curl bash
else
    echo "Unsupported package manager. Install zsh/git/curl manually." >&2
    exit 1
fi

echo "==> Installing oh-my-zsh (unattended, keeps existing .zshrc if present)"
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    KEEP_ZSHRC=yes RUNZSH=no CHSH=no \
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
    echo "    oh-my-zsh already installed, skipping"
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

clone_plugin () {
    local name="$1" url="$2"
    if [ ! -d "$ZSH_CUSTOM/plugins/$name" ]; then
        echo "==> Installing plugin: $name"
        git clone --depth 1 "$url" "$ZSH_CUSTOM/plugins/$name"
    else
        echo "    plugin $name already present, skipping"
    fi
}

clone_plugin zsh-autosuggestions   https://github.com/zsh-users/zsh-autosuggestions
clone_plugin zsh-syntax-highlighting https://github.com/zsh-users/zsh-syntax-highlighting
# Pick ONE syntax highlighter to avoid conflicts — fast-syntax-highlighting is the faster
# alternative to zsh-syntax-highlighting above. Comment one of the two out if you only want one.
clone_plugin fast-syntax-highlighting https://github.com/zdharma-continuum/fast-syntax-highlighting
clone_plugin zsh-autocomplete      https://github.com/marlonrichert/zsh-autocomplete

echo "==> Writing ~/.zshrc"
cat > "$HOME/.zshrc" <<'EOF'
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="bira"

plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
  fast-syntax-highlighting
  zsh-autocomplete
)

source $ZSH/oh-my-zsh.sh
EOF

echo "==> Setting zsh as default shell"
ZSH_PATH="$(command -v zsh)"
if ! grep -qx "$ZSH_PATH" /etc/shells; then
    echo "$ZSH_PATH" | sudo tee -a /etc/shells >/dev/null
fi
sudo chsh -s "$ZSH_PATH" "$(whoami)"

echo "==> Done. Run 'exec zsh' now, or exit twice (exit; exit) and reconnect via SSH to start using it."
echo "==> For VS Code Remote-SSH, also add to Remote Settings (JSON) on this host:"
cat <<'EOF'
{
  "terminal.integrated.defaultProfile.linux": "zsh",
  "terminal.integrated.profiles.linux": {
    "zsh": { "path": "$(command -v zsh)" }
  }
}
EOF
