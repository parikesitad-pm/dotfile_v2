#!/usr/bin/env bash
# ==============================================================================
# Dotfiles Automated Setup Script
# Target: Manjaro GNOME (Arch-based)
# Developer: parikesitad-pm
# ==============================================================================

set -euo pipefail

# -------------------------------
# Colors & Logging
# -------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

info() {
    echo -e "${BLUE}[INFO]${NC} $*"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $*"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $*"
}

error() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
}

# -------------------------------
# Environment & Base Paths
# -------------------------------
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_SUFFIX=".bak.$(date +%Y%m%d_%H%M%S)"

DRY_RUN=false
SKIP_PACKAGES=false
SKIP_EXTENSIONS=false

print_help() {
    cat << HELP_MSG
Usage: ./setup.sh [OPTIONS]

Options:
  --dry-run          Simulate actions without modifying files or installing packages
  --skip-packages    Skip pacman/yay core package installations
  --skip-extensions  Skip VS Code extensions installation
  -h, --help         Show this help message
HELP_MSG
}

for arg in "$@"; do
    case $arg in
        --dry-run)
            DRY_RUN=true
            ;;
        --skip-packages)
            SKIP_PACKAGES=true
            ;;
        --skip-extensions)
            SKIP_EXTENSIONS=true
            ;;
        -h|--help)
            print_help
            exit 0
            ;;
        *)
            warn "Unknown argument: $arg"
            ;;
    esac
done

echo -e "${CYAN}====================================================${NC}"
echo -e "${CYAN}  Dotfiles Deployment for Manjaro GNOME (Arch-based)${NC}"
echo -e "${CYAN}====================================================${NC}"
info "Dotfiles Source Directory: $DOTFILES_DIR"
if [ "$DRY_RUN" = true ]; then
    warn "Running in DRY-RUN mode. No changes will be written."
fi

# -------------------------------
# Safe Symlink Helper
# -------------------------------
backup_and_symlink() {
    local src="$1"
    local dest="$2"

    if [ ! -e "$src" ]; then
        error "Source file/dir does not exist: $src"
        return 1
    fi

    local dest_dir
    dest_dir="$(dirname "$dest")"
    if [ ! -d "$dest_dir" ]; then
        if [ "$DRY_RUN" = true ]; then
            info "[DRY-RUN] Would create directory: $dest_dir"
        else
            mkdir -p "$dest_dir"
        fi
    fi

    if [ -e "$dest" ] || [ -L "$dest" ]; then
        if [ -L "$dest" ] && [ "$(readlink -f "$dest")" = "$(readlink -f "$src")" ]; then
            info "Symlink already points to source: $dest -> $src"
            return 0
        fi

        local backup="${dest}${BACKUP_SUFFIX}"
        if [ "$DRY_RUN" = true ]; then
            warn "[DRY-RUN] Would backup existing $dest to $backup"
        else
            warn "Backing up existing $dest to $backup"
            mv "$dest" "$backup"
        fi
    fi

    if [ "$DRY_RUN" = true ]; then
        success "[DRY-RUN] Would symlink: $dest -> $src"
    else
        ln -sfn "$src" "$dest"
        success "Linked: $dest -> $src"
    fi
}

# -------------------------------
# 1. Package Installation (Pacman/Yay)
# -------------------------------
install_core_packages() {
    if [ "$SKIP_PACKAGES" = true ]; then
        info "Skipping package installation (--skip-packages active)."
        return 0
    fi

    info "Checking core packages (kitty, starship, git, curl, zsh)..."
    local CORE_PKGS=("kitty" "starship" "git" "curl" "zsh")

    if command -v pacman >/dev/null 2>&1; then
        if [ "$DRY_RUN" = true ]; then
            info "[DRY-RUN] Would run: sudo pacman -S --needed --noconfirm ${CORE_PKGS[*]}"
        else
            info "Running: sudo pacman -S --needed --noconfirm ${CORE_PKGS[*]}"
            sudo pacman -S --needed --noconfirm "${CORE_PKGS[@]}"
            success "Core packages installed."
        fi
    else
        warn "pacman not found. If not on Arch/Manjaro, please install ${CORE_PKGS[*]} manually."
    fi
}

# -------------------------------
# 2. Symlink Configurations
# -------------------------------
deploy_symlinks() {
    info "Setting up configuration symlinks..."

    # 1. Kitty Terminal
    backup_and_symlink "$DOTFILES_DIR/kitty" "$HOME/.config/kitty"

    # 2. Starship Prompt
    backup_and_symlink "$DOTFILES_DIR/starship/starship.toml" "$HOME/.config/starship.toml"

    # 3. Shell & Git
    backup_and_symlink "$DOTFILES_DIR/shell/.bashrc" "$HOME/.bashrc"
    backup_and_symlink "$DOTFILES_DIR/shell/.zshrc" "$HOME/.zshrc"
    backup_and_symlink "$DOTFILES_DIR/git/.gitconfig" "$HOME/.gitconfig"

    # 4. VS Code Configurations
    local VSCODE_TARGET_DIRS=("$HOME/.config/Code/User")
    [ -d "$HOME/.config/Code - OSS/User" ] && VSCODE_TARGET_DIRS+=("$HOME/.config/Code - OSS/User")
    [ -d "$HOME/.config/VSCodium/User" ] && VSCODE_TARGET_DIRS+=("$HOME/.config/VSCodium/User")

    for target_dir in "${VSCODE_TARGET_DIRS[@]}"; do
        info "Configuring editor target: $target_dir"
        backup_and_symlink "$DOTFILES_DIR/vscode/settings.json" "$target_dir/settings.json"
        backup_and_symlink "$DOTFILES_DIR/vscode/keybindings.json" "$target_dir/keybindings.json"
        backup_and_symlink "$DOTFILES_DIR/vscode/snippets" "$target_dir/snippets"
    done
}

# -------------------------------
# 3. VS Code Extensions Restore
# -------------------------------
restore_vscode_extensions() {
    if [ "$SKIP_EXTENSIONS" = true ]; then
        info "Skipping VS Code extensions installation (--skip-extensions active)."
        return 0
    fi

    local EXT_FILE="$DOTFILES_DIR/vscode/extensions.list"
    if [ ! -f "$EXT_FILE" ]; then
        warn "Extension list not found at: $EXT_FILE"
        return 0
    fi

    local EDITOR_BIN=""
    if command -v code >/dev/null 2>&1; then
        EDITOR_BIN="code"
    elif command -v codium >/dev/null 2>&1; then
        EDITOR_BIN="codium"
    elif command -v code-oss >/dev/null 2>&1; then
        EDITOR_BIN="code-oss"
    fi

    if [ -z "$EDITOR_BIN" ]; then
        warn "VS Code binary ('code', 'codium', or 'code-oss') not found. Extensions can be installed later using: ./setup.sh --skip-packages"
        return 0
    fi

    info "Restoring VS Code extensions using $EDITOR_BIN..."
    while IFS= read -r ext || [ -n "$ext" ]; do
        # Ignore comments and empty lines
        [[ "$ext" =~ ^[[:space:]]*# ]] && continue
        [ -z "$ext" ] && continue

        if [ "$DRY_RUN" = true ]; then
            info "[DRY-RUN] Would install extension: $ext"
        else
            echo -e "Installing extension: ${CYAN}$ext${NC}..."
            "$EDITOR_BIN" --install-extension "$ext" --force || warn "Failed to install $ext"
        fi
    done < "$EXT_FILE"

    success "VS Code extensions restoration finished."
}

# -------------------------------
# 4. Starship Prompt Hook Injection
# -------------------------------
ensure_starship_hook() {
    info "Verifying Starship prompt initialization in shell RC files..."

    # In Bash
    local BASHRC="$HOME/.bashrc"
    if [ -f "$BASHRC" ]; then
        if ! grep -q 'starship init bash' "$BASHRC"; then
            if [ "$DRY_RUN" = true ]; then
                info "[DRY-RUN] Would append Starship init hook to $BASHRC"
            else
                info "Injecting Starship init into $BASHRC"
                cat << 'STARSHIP_BASH' >> "$BASHRC"

# Starship Prompt Hook
eval "$(starship init bash)"
STARSHIP_BASH
                success "Starship hook added to $BASHRC"
            fi
        else
            info "Starship hook already present in $BASHRC"
        fi
    fi

    # In Zsh
    local ZSHRC="$HOME/.zshrc"
    if [ -f "$ZSHRC" ]; then
        if ! grep -q 'starship init zsh' "$ZSHRC"; then
            if [ "$DRY_RUN" = true ]; then
                info "[DRY-RUN] Would append Starship init hook to $ZSHRC"
            else
                info "Injecting Starship init into $ZSHRC"
                cat << 'STARSHIP_ZSH' >> "$ZSHRC"

# Starship Prompt Hook
eval "$(starship init zsh)"
STARSHIP_ZSH
                success "Starship hook added to $ZSHRC"
            fi
        else
            info "Starship hook already present in $ZSHRC"
        fi
    fi
}

# -------------------------------
# Main Execution Flow
# -------------------------------
main() {
    install_core_packages
    deploy_symlinks
    ensure_starship_hook
    restore_vscode_extensions

    echo -e "\n${GREEN}====================================================${NC}"
    echo -e "${GREEN}  Dotfiles deployment completed successfully!       ${NC}"
    echo -e "${GREEN}====================================================${NC}"
    info "Next steps on Manjaro GNOME:"
    echo -e "  1. Switch default shell if needed: ${CYAN}chsh -s \$(which zsh)${NC}"
    echo -e "  2. Install Oh My Zsh if not present: ${CYAN}sh -c \"\$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)\"${NC}"
    echo -e "  3. Open Kitty and VS Code to verify appearance."
}

main "$@"
