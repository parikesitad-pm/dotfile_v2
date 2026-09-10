#!/usr/bin/env bash
# ==============================================================================
# ARCHITECTURE: Atomic Design Pipeline (Atoms -> Molecules -> Organisms -> Templates -> Pages)
# PATTERNS: SOLID / DRY / Zero Magic Numbers / Idempotent / Non-Destructive Execution
# TARGET: Manjaro Linux (GNOME Desktop / Wayland)
# DEVELOPER: parikesitad-pm
# ==============================================================================

set -euo pipefail

# ==============================================================================
# ⚛️ ATOMS: Logging, Configuration Primitives & Environment Constants
# ==============================================================================
readonly COLOR_RED='\033[0;31m'
readonly COLOR_GREEN='\033[0;32m'
readonly COLOR_YELLOW='\033[1;33m'
readonly COLOR_BLUE='\033[0;34m'
readonly COLOR_CYAN='\033[0;36m'
readonly COLOR_NC='\033[0m'

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly DOTFILES_DIR="${SCRIPT_DIR}"
readonly TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
readonly BACKUP_DIR="${HOME}/.dotfiles_backup/${TIMESTAMP}"

# Flags
DRY_RUN=false
SKIP_PACKAGES=false
SKIP_EXTENSIONS=false
SKIP_SHORTCUTS=false

log_info() {
    echo -e "${COLOR_BLUE}[INFO]${COLOR_NC} $*"
}

log_success() {
    echo -e "${COLOR_GREEN}[SUCCESS]${COLOR_NC} $*"
}

log_warn() {
    echo -e "${COLOR_YELLOW}[WARN]${COLOR_NC} $*"
}

log_error() {
    echo -e "${COLOR_RED}[ERROR]${COLOR_NC} $*" >&2
}

log_skip() {
    echo "[INSTALLED: SKIP] $*"
}

log_install() {
    echo "[INSTALLING] $*"
}

# ==============================================================================
# 🧬 MOLECULES: System Verification & Safe Idempotent Operations
# ==============================================================================
is_native_pkg_installed() {
    local pkg="$1"
    pacman -Qi "${pkg}" >/dev/null 2>&1
}

is_aur_pkg_installed() {
    local pkg="$1"
    pacman -Qi "${pkg}" >/dev/null 2>&1 || yay -Qi "${pkg}" >/dev/null 2>&1
}

is_extension_installed() {
    local ext="$1"
    if command -v code >/dev/null 2>&1; then
        code --list-extensions 2>/dev/null | grep -qx "${ext}"
    else
        return 1
    fi
}

ensure_parent_dir() {
    local target_path="$1"
    local parent_dir
    parent_dir="$(dirname "${target_path}")"
    if [[ ! -d "${parent_dir}" ]]; then
        if [[ "${DRY_RUN}" = true ]]; then
            log_info "[DRY-RUN] mkdir -p ${parent_dir}"
        else
            mkdir -p "${parent_dir}"
        fi
    fi
}

atomic_symlink() {
    local src="$1"
    local dest="$2"

    if [[ ! -e "${src}" ]]; then
        log_error "Source file/dir does not exist: ${src}"
        return 1
    fi

    ensure_parent_dir "${dest}"

    # Verify if destination is already an identical symlink
    if [[ -L "${dest}" ]] && [[ "$(readlink -f "${dest}")" = "$(readlink -f "${src}")" ]]; then
        log_info "Symlink verified: ${dest} -> ${src}"
        return 0
    fi

    # Non-destructive backup of existing file/directory/symlink
    if [[ -e "${dest}" ]] || [[ -L "${dest}" ]]; then
        if [[ "${DRY_RUN}" = true ]]; then
            log_warn "[DRY-RUN] Would backup existing ${dest} to ${BACKUP_DIR}/$(basename "${dest}")"
        else
            mkdir -p "${BACKUP_DIR}"
            local dest_name
            dest_name="$(basename "${dest}")"
            log_warn "Backing up ${dest} -> ${BACKUP_DIR}/${dest_name}"
            cp -a "${dest}" "${BACKUP_DIR}/${dest_name}"
            rm -rf "${dest}"
        fi
    fi

    # Atomic symlink creation
    if [[ "${DRY_RUN}" = true ]]; then
        log_success "[DRY-RUN] ln -sf ${src} ${dest}"
    else
        ln -sf "${src}" "${dest}"
        log_success "Linked: ${dest} -> ${src}"
    fi
}

# ==============================================================================
# 🦠 ORGANISMS: Pipeline Execution Phases
# ==============================================================================

# ------------------------------------------------------------------------------
# Phase A: Core Apps & AUR Packages
# ------------------------------------------------------------------------------
phase_a_core_and_aur() {
    log_info "=== [Phase A] Core Native Apps & AUR Packages ==="

    # 1. Official Repository Packages
    local OFFICIAL_PKGS=(
        "base-devel"
        "git"
        "curl"
        "wget"
        "btop"
        "fastfetch"
        "firefox"
        "discord"
        "zsh"
        "zsh-autosuggestions"
        "zsh-syntax-highlighting"
        "github-cli"
        "eza"
        "zoxide"
        "gnome-keyring"
        "libsecret"
        "seahorse"
        "kitty"
        "starship"
        "bat"
        "fd"
        "ripgrep"
        "fzf"
        "wl-clipboard"
    )

    local MISSING_OFFICIAL=()
    for pkg in "${OFFICIAL_PKGS[@]}"; do
        if is_native_pkg_installed "${pkg}"; then
            log_skip "${pkg}"
        else
            MISSING_OFFICIAL+=("${pkg}")
        fi
    done

    if [[ ${#MISSING_OFFICIAL[@]} -gt 0 ]]; then
        for pkg in "${MISSING_OFFICIAL[@]}"; do
            log_install "${pkg}"
        done
        if [[ "${DRY_RUN}" = true ]]; then
            log_info "[DRY-RUN] sudo pacman -S --needed --noconfirm ${MISSING_OFFICIAL[*]}"
        else
            sudo pacman -S --needed --noconfirm "${MISSING_OFFICIAL[@]}"
            log_success "Official packages installed."
        fi
    fi

    # 2. AUR Helper (yay) Verification
    if command -v yay >/dev/null 2>&1; then
        log_skip "yay"
    else
        log_install "yay (from AUR git source)"
        local BUILD_DIR="/tmp/yay_build"
        if [[ "${DRY_RUN}" = true ]]; then
            log_info "[DRY-RUN] git clone https://aur.archlinux.org/yay.git ${BUILD_DIR} && cd ${BUILD_DIR} && makepkg -si --noconfirm"
        else
            rm -rf "${BUILD_DIR}"
            git clone https://aur.archlinux.org/yay.git "${BUILD_DIR}"
            (
                cd "${BUILD_DIR}"
                makepkg -si --noconfirm
            )
            rm -rf "${BUILD_DIR}"
            log_success "yay installed successfully."
        fi
    fi

    # 3. AUR Packages Installation
    local AUR_PKGS=(
        "ulauncher"
        "google-chrome"
        "visual-studio-code-bin"
        "spotify"
        "zapzap"
    )

    for pkg in "${AUR_PKGS[@]}"; do
        if is_aur_pkg_installed "${pkg}"; then
            log_skip "${pkg}"
        else
            log_install "${pkg}"
            if [[ "${DRY_RUN}" = true ]]; then
                log_info "[DRY-RUN] yay -S --noconfirm ${pkg}"
            else
                yay -S --noconfirm "${pkg}"
            fi
        fi
    done

    # 4. Enable Ulauncher Daemon
    log_info "Configuring Ulauncher user daemon..."
    if [[ "${DRY_RUN}" = true ]]; then
        log_info "[DRY-RUN] systemctl --user enable --now ulauncher"
    else
        systemctl --user enable --now ulauncher 2>/dev/null || log_warn "Ulauncher daemon will activate upon graphical session login."
    fi
}

# ------------------------------------------------------------------------------
# Phase B: Fonts Installation & Cache Refresh
# ------------------------------------------------------------------------------
phase_b_fonts() {
    log_info "=== [Phase B] Fonts Installation & Cache Refresh ==="
    local FONTS=(
        "ttf-jetbrains-mono-nerd"
        "noto-fonts-emoji"
    )

    local MISSING_FONTS=()
    for font_pkg in "${FONTS[@]}"; do
        if is_native_pkg_installed "${font_pkg}"; then
            log_skip "${font_pkg}"
        else
            MISSING_FONTS+=("${font_pkg}")
        fi
    done

    if [[ ${#MISSING_FONTS[@]} -gt 0 ]]; then
        for font_pkg in "${MISSING_FONTS[@]}"; do
            log_install "${font_pkg}"
        done
        if [[ "${DRY_RUN}" = true ]]; then
            log_info "[DRY-RUN] sudo pacman -S --needed --noconfirm ${MISSING_FONTS[*]}"
        else
            sudo pacman -S --needed --noconfirm "${MISSING_FONTS[@]}"
        fi
    fi

    log_info "Refreshing font cache..."
    if [[ "${DRY_RUN}" = true ]]; then
        log_info "[DRY-RUN] fc-cache -f"
    else
        fc-cache -f
        log_success "Font cache refreshed."
    fi
}

# ------------------------------------------------------------------------------
# Phase C: macOS-style Shortcuts on GNOME via gsettings & System Tweaks
# ------------------------------------------------------------------------------
phase_c_macos_shortcuts() {
    if [[ "${SKIP_SHORTCUTS}" = true ]]; then
        log_info "Skipping macOS shortcuts (--skip-shortcuts active)."
        return 0
    fi

    log_info "=== [Phase C] macOS-style Shortcuts & GNOME Performance Tweaks ==="

    if ! command -v gsettings >/dev/null 2>&1; then
        log_warn "gsettings not found, skipping GNOME shortcut configuration."
        return 0
    fi

    if [[ "${DRY_RUN}" = true ]]; then
        log_info "[DRY-RUN] Configure GNOME shortcuts (Super+Shift+3, Super+Shift+4, Super+Shift+5, Super+Q, Super+H)"
        log_info "[DRY-RUN] Disable GNOME interface animations"
        log_info "[DRY-RUN] Mask tracker miner services"
    else
        # Super+Shift+3: Fullscreen capture
        gsettings set org.gnome.shell.keybindings screenshot "['<Super><Shift>3']"
        # Super+Shift+4: Area/window capture
        gsettings set org.gnome.shell.keybindings screenshot-window "['<Super><Shift>4']"
        # Super+Shift+5: Screenshot UI
        gsettings set org.gnome.shell.keybindings show-screenshot-ui "['<Super><Shift>5']"
        # Super+Q: Close window
        gsettings set org.gnome.desktop.wm.keybindings close "['<Super>q']"
        # Super+H: Minimize window
        gsettings set org.gnome.desktop.wm.keybindings minimize "['<Super>h']"

        # Disable GNOME animations for instantaneous response
        gsettings set org.gnome.desktop.interface enable-animations false

        # Mask resource-heavy tracker miners
        systemctl --user mask tracker-miner-fs-3.service tracker-miner-rss-3.service 2>/dev/null || true

        log_success "macOS-style shortcuts and GNOME system tweaks applied."
    fi
}

# ------------------------------------------------------------------------------
# Phase D: Shell Normalization, Symlinks & Extension Restore
# ------------------------------------------------------------------------------
phase_d_shell_and_symlinks() {
    log_info "=== [Phase D] Shell Normalization, Symlinks & Extension Restore ==="

    # 1. Shell Links
    atomic_symlink "${DOTFILES_DIR}/shell/.zshrc" "${HOME}/.zshrc"
    atomic_symlink "${DOTFILES_DIR}/shell/.bashrc" "${HOME}/.bashrc"

    # 2. Config Links
    atomic_symlink "${DOTFILES_DIR}/starship/starship.toml" "${HOME}/.config/starship.toml"
    atomic_symlink "${DOTFILES_DIR}/kitty" "${HOME}/.config/kitty"
    atomic_symlink "${DOTFILES_DIR}/git/.gitconfig" "${HOME}/.gitconfig"

    # 3. VS Code Configurations
    local VSCODE_USER_DIR="${HOME}/.config/Code/User"
    atomic_symlink "${DOTFILES_DIR}/vscode/settings.json" "${VSCODE_USER_DIR}/settings.json"
    atomic_symlink "${DOTFILES_DIR}/vscode/keybindings.json" "${VSCODE_USER_DIR}/keybindings.json"
    if [[ -e "${DOTFILES_DIR}/vscode/snippets" ]]; then
        atomic_symlink "${DOTFILES_DIR}/vscode/snippets" "${VSCODE_USER_DIR}/snippets"
    fi

    # 4. VS Code Extensions Restore
    if [[ "${SKIP_EXTENSIONS}" = true ]]; then
        log_info "Skipping VS Code extensions (--skip-extensions active)."
        return 0
    fi

    local EXT_FILE="${DOTFILES_DIR}/vscode/extensions.list"
    if [[ ! -f "${EXT_FILE}" ]]; then
        log_warn "Extension list not found: ${EXT_FILE}"
        return 0
    fi

    if ! command -v code >/dev/null 2>&1; then
        log_warn "VS Code CLI ('code') not found. Extensions can be installed after installing VS Code."
        return 0
    fi

    log_info "Verifying VS Code extensions..."
    local CURRENT_EXTS
    CURRENT_EXTS="$(code --list-extensions 2>/dev/null || true)"

    while IFS= read -r ext || [[ -n "${ext}" ]]; do
        [[ "${ext}" =~ ^[[:space:]]*# ]] && continue
        [[ -z "${ext// }" ]] && continue

        if echo "${CURRENT_EXTS}" | grep -qx "${ext}"; then
            log_skip "${ext}"
        else
            log_install "${ext}"
            if [[ "${DRY_RUN}" = true ]]; then
                log_info "[DRY-RUN] code --install-extension ${ext} --force"
            else
                code --install-extension "${ext}" --force || log_warn "Failed to install extension: ${ext}"
            fi
        fi
    done < "${EXT_FILE}"

    log_success "VS Code extension verification completed."
}

# ==============================================================================
# 📐 TEMPLATES: Pipeline Orchestration
# ==============================================================================
print_banner() {
    echo -e "${COLOR_CYAN}====================================================${COLOR_NC}"
    echo -e "${COLOR_CYAN}  Manjaro GNOME Automated Dotfiles Setup Pipeline   ${COLOR_NC}"
    echo -e "${COLOR_CYAN}====================================================${COLOR_NC}"
    log_info "Source Directory : ${DOTFILES_DIR}"
    log_info "Backup Directory : ${BACKUP_DIR}"
    if [[ "${DRY_RUN}" = true ]]; then
        log_warn "Execution Mode   : DRY-RUN (No system changes will occur)"
    fi
}

run_pipeline() {
    print_banner

    if [[ "${SKIP_PACKAGES}" = false ]]; then
        phase_a_core_and_aur
        phase_b_fonts
    else
        log_info "Package installation bypassed (--skip-packages active)."
    fi

    phase_c_macos_shortcuts
    phase_d_shell_and_symlinks

    echo -e "\n${COLOR_GREEN}====================================================${COLOR_NC}"
    echo -e "${COLOR_GREEN}  Pipeline execution completed successfully!        ${COLOR_NC}"
    echo -e "${COLOR_GREEN}====================================================${COLOR_NC}"
    log_info "To apply shell changes in current terminal: source ~/.zshrc"
}

# ==============================================================================
# 📄 PAGES: CLI Entrypoint & Flags
# ==============================================================================
print_help() {
    cat << HELP_TEXT
Usage: ./setup.sh [OPTIONS]

Pipeline Orchestrator for Manjaro GNOME Dotfiles.

Options:
  --dry-run          Simulate pipeline execution without changing the filesystem or packages
  --skip-packages    Skip native pacman, yay, and AUR package installations
  --skip-extensions  Skip VS Code extensions installation
  --skip-shortcuts   Skip GNOME macOS shortcuts and system tweaks
  -h, --help         Display this help message
HELP_TEXT
}

main() {
    for arg in "$@"; do
        case "${arg}" in
            --dry-run)
                DRY_RUN=true
                ;;
            --skip-packages)
                SKIP_PACKAGES=true
                ;;
            --skip-extensions)
                SKIP_EXTENSIONS=true
                ;;
            --skip-shortcuts)
                SKIP_SHORTCUTS=true
                ;;
            -h|--help)
                print_help
                exit 0
                ;;
            *)
                log_warn "Unrecognized option: ${arg}"
                ;;
        esac
    done

    run_pipeline
}

main "$@"
