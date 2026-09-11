#!/usr/bin/env bash
# ==============================================================================
# ARCHITECTURE: Atomic Design Pipeline (Atoms -> Molecules -> Organisms -> Templates -> Pages)
# PATTERNS: SOLID / DRY / Zero Magic Numbers / Idempotent / Non-Destructive Execution
# TARGET: Manjaro Linux (GNOME Desktop / Wayland)
# DEVELOPER: parikesitad-pm
# ==============================================================================

set -euo pipefail

# ==============================================================================
# ⚛️ ATOMS: Styling, Configuration Primitives & Environment Constants
# ==============================================================================
readonly COLOR_RED='\033[1;31m'
readonly COLOR_GREEN='\033[1;32m'
readonly COLOR_YELLOW='\033[1;33m'
readonly COLOR_BLUE='\033[1;34m'
readonly COLOR_MAGENTA='\033[1;35m'
readonly COLOR_CYAN='\033[1;36m'
readonly COLOR_WHITE='\033[1;37m'
readonly COLOR_DIM='\033[0;90m'
readonly COLOR_NC='\033[0m'

# Nerd Font Glyphs
readonly GLYPH_MANJARO=' '
readonly GLYPH_CHECK='✔'
readonly GLYPH_CROSS='✖'
readonly GLYPH_SKIP=''
readonly GLYPH_DOWNLOAD=''
readonly GLYPH_LINK=''
readonly GLYPH_BACKUP='󰁯'
readonly GLYPH_INFO='󰋽'
readonly GLYPH_WARN=''
readonly GLYPH_PACKAGE=''
readonly GLYPH_FONT=''
readonly GLYPH_KEYBOARD='󰌌'
readonly GLYPH_SPARKLE='✨'

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly DOTFILES_DIR="${SCRIPT_DIR}"
readonly TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
readonly BACKUP_DIR="${HOME}/.dotfiles_backup/${TIMESTAMP}"

# Flags
DRY_RUN=false
SKIP_PACKAGES=false
SKIP_EXTENSIONS=false
SKIP_SHORTCUTS=false

# Cursor safety cleanup
trap 'tput cnorm 2>/dev/null || true' EXIT INT TERM

log_header() {
    local title="$1"
    echo -e "\n${COLOR_CYAN}╭─ ${title} ${COLOR_CYAN}$(printf '─%.0s' $(seq 1 $((58 - ${#title}))))${COLOR_NC}"
}

log_footer() {
    echo -e "${COLOR_CYAN}╰─────────────────────────────────────────────────────────────${COLOR_NC}"
}

log_info() {
    echo -e "  ${COLOR_BLUE}${GLYPH_INFO}${COLOR_NC}  ${COLOR_DIM}[INFO]${COLOR_NC}           $*"
}

log_success() {
    echo -e "  ${COLOR_GREEN}${GLYPH_CHECK}${COLOR_NC}  ${COLOR_GREEN}[SUCCESS]${COLOR_NC}        $*"
}

log_warn() {
    echo -e "  ${COLOR_YELLOW}${GLYPH_WARN}${COLOR_NC}  ${COLOR_YELLOW}[WARN]${COLOR_NC}           $*"
}

log_error() {
    echo -e "  ${COLOR_RED}${GLYPH_CROSS}${COLOR_NC}  ${COLOR_RED}[ERROR]${COLOR_NC}          $*" >&2
}

log_skip() {
    echo -e "  ${COLOR_GREEN}${GLYPH_SKIP}${COLOR_NC}  ${COLOR_DIM}[INSTALLED: SKIP]${COLOR_NC} $*"
}

log_install() {
    echo -e "  ${COLOR_CYAN}${GLYPH_DOWNLOAD}${COLOR_NC}  ${COLOR_CYAN}[INSTALLING]${COLOR_NC}     $*"
}

log_verified() {
    echo -e "  ${COLOR_GREEN}${GLYPH_SKIP}${COLOR_NC}  ${COLOR_DIM}[VERIFIED]${COLOR_NC}       $*"
}

log_linked() {
    local dest="$1"
    local src="$2"
    echo -e "  ${COLOR_MAGENTA}${GLYPH_LINK}${COLOR_NC}  ${COLOR_MAGENTA}[LINKED]${COLOR_NC}         ${dest} ${COLOR_DIM}-> ${src}${COLOR_NC}"
}

log_backup() {
    local dest="$1"
    local backup="$2"
    echo -e "  ${COLOR_YELLOW}${GLYPH_BACKUP}${COLOR_NC}  ${COLOR_YELLOW}[BACKUP]${COLOR_NC}         ${dest} ${COLOR_DIM}-> ${backup}${COLOR_NC}"
}

# ==============================================================================
# 🌀 ANIMATION ENGINE: Non-blocking Worker with Live Spinner
# ==============================================================================
spin_task() {
    local message="$1"
    shift
    local cmd=("$@")

    if [[ "${DRY_RUN}" = true ]]; then
        echo -e "  ${COLOR_CYAN}⠋${COLOR_NC} ${message}... ${COLOR_YELLOW}[DRY-RUN]${COLOR_NC}"
        return 0
    fi

    # Fallback for non-interactive / non-TTY environments
    if [[ ! -t 1 ]]; then
        echo -e "  ${COLOR_CYAN}➜${COLOR_NC} ${message}..."
        "${cmd[@]}" >/dev/null 2>&1
        echo -e "  ${COLOR_GREEN}${GLYPH_CHECK}${COLOR_NC} ${message} completed."
        return 0
    fi

    local spin_chars=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
    local log_file
    log_file="$(mktemp)"

    tput civis 2>/dev/null || true # Hide cursor

    # Run command in background
    "${cmd[@]}" >"${log_file}" 2>&1 &
    local task_pid=$!

    local i=0
    while kill -0 "${task_pid}" 2>/dev/null; do
        local frame="${spin_chars[i % 10]}"
        printf "\r  \033[1;36m%s\033[0m %s... " "${frame}" "${message}"
        ((i++))
        sleep 0.08
    done

    wait "${task_pid}"
    local exit_code=$?
    tput cnorm 2>/dev/null || true # Restore cursor

    if [[ ${exit_code} -eq 0 ]]; then
        printf "\r  \033[1;32m%s\033[0m %s \033[1;32m[DONE]\033[0m          \n" "${GLYPH_CHECK}" "${message}"
        rm -f "${log_file}"
        return 0
    else
        printf "\r  \033[1;31m%s\033[0m %s \033[1;31m[FAILED]\033[0m        \n" "${GLYPH_CROSS}" "${message}"
        cat "${log_file}" >&2
        rm -f "${log_file}"
        return ${exit_code}
    fi
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
        log_verified "${dest} -> ${src}"
        return 0
    fi

    # Non-destructive backup of existing file/directory/symlink
    if [[ -e "${dest}" ]] || [[ -L "${dest}" ]]; then
        local dest_name
        dest_name="$(basename "${dest}")"
        if [[ "${DRY_RUN}" = true ]]; then
            log_backup "${dest}" "${BACKUP_DIR}/${dest_name} [DRY-RUN]"
        else
            mkdir -p "${BACKUP_DIR}"
            log_backup "${dest}" "${BACKUP_DIR}/${dest_name}"
            cp -a "${dest}" "${BACKUP_DIR}/${dest_name}"
            rm -rf "${dest}"
        fi
    fi

    # Atomic symlink creation
    if [[ "${DRY_RUN}" = true ]]; then
        log_linked "${dest}" "${src} [DRY-RUN]"
    else
        ln -sf "${src}" "${dest}"
        log_linked "${dest}" "${src}"
    fi
}

# ==============================================================================
# 🦠 ORGANISMS: Pipeline Execution Phases
# ==============================================================================

# ------------------------------------------------------------------------------
# Phase A: Core Apps & AUR Packages
# ------------------------------------------------------------------------------
phase_a_core_and_aur() {
    log_header "${GLYPH_PACKAGE}  Phase A: Core Native Apps & AUR Packages"

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
        spin_task "Installing native packages via pacman" sudo pacman -S --needed --noconfirm "${MISSING_OFFICIAL[@]}"
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
                spin_task "Compiling and installing yay" makepkg -si --noconfirm
            )
            rm -rf "${BUILD_DIR}"
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
            spin_task "Installing AUR package: ${pkg}" yay -S --noconfirm "${pkg}"
        fi
    done

    # 4. Enable Ulauncher Daemon
    if [[ "${DRY_RUN}" = true ]]; then
        log_info "Ulauncher user daemon activation [DRY-RUN]"
    else
        spin_task "Enabling Ulauncher user service" bash -c "systemctl --user enable --now ulauncher 2>/dev/null || true"
    fi

    log_footer
}

# ------------------------------------------------------------------------------
# Phase B: Fonts Installation & Cache Refresh
# ------------------------------------------------------------------------------
phase_b_fonts() {
    log_header "${GLYPH_FONT}  Phase B: Fonts Installation & Cache Refresh"

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
        spin_task "Installing font packages" sudo pacman -S --needed --noconfirm "${MISSING_FONTS[@]}"
    fi

    spin_task "Refreshing font cache (fc-cache)" fc-cache -f

    log_footer
}

# ------------------------------------------------------------------------------
# Phase C: macOS-style Shortcuts on GNOME via gsettings & System Tweaks
# ------------------------------------------------------------------------------
phase_c_macos_shortcuts() {
    if [[ "${SKIP_SHORTCUTS}" = true ]]; then
        log_info "Skipping macOS shortcuts (--skip-shortcuts active)."
        return 0
    fi

    log_header "${GLYPH_KEYBOARD}  Phase C: macOS Shortcuts & GNOME Performance"

    if ! command -v gsettings >/dev/null 2>&1; then
        log_warn "gsettings not found, skipping GNOME shortcut configuration."
        log_footer
        return 0
    fi

    if [[ "${DRY_RUN}" = true ]]; then
        log_info "Configure GNOME shortcuts (Super+Shift+3, Super+Shift+4, Super+Shift+5, Super+Q, Super+H) [DRY-RUN]"
        log_info "Disable GNOME interface animations [DRY-RUN]"
        log_info "Mask tracker miner background services [DRY-RUN]"
    else
        spin_task "Configuring macOS-style screenshot shortcuts" bash -c "
            gsettings set org.gnome.shell.keybindings screenshot \"['<Super><Shift>3']\"
            gsettings set org.gnome.shell.keybindings screenshot-window \"['<Super><Shift>4']\"
            gsettings set org.gnome.shell.keybindings show-screenshot-ui \"['<Super><Shift>5']\"
        "

        spin_task "Configuring macOS-style window controls (Super+Q, Super+H)" bash -c "
            gsettings set org.gnome.desktop.wm.keybindings close \"['<Super>q']\"
            gsettings set org.gnome.desktop.wm.keybindings minimize \"['<Super>h']\"
        "

        spin_task "Disabling GNOME UI animations for instant response" gsettings set org.gnome.desktop.interface enable-animations false

        spin_task "Masking resource-heavy tracker miners" bash -c "systemctl --user mask tracker-miner-fs-3.service tracker-miner-rss-3.service 2>/dev/null || true"
    fi

    log_footer
}

# ------------------------------------------------------------------------------
# Phase D: Shell Normalization, Symlinks & Extension Restore
# ------------------------------------------------------------------------------
phase_d_shell_and_symlinks() {
    log_header "${GLYPH_LINK}  Phase D: Shell Normalization & Application Symlinks"

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
    else
        local EXT_FILE="${DOTFILES_DIR}/vscode/extensions.list"
        if [[ -f "${EXT_FILE}" ]] && command -v code >/dev/null 2>&1; then
            echo -e "  ${COLOR_CYAN}➜${COLOR_NC} ${COLOR_WHITE}Verifying VS Code extensions...${COLOR_NC}"
            local CURRENT_EXTS
            CURRENT_EXTS="$(code --list-extensions 2>/dev/null || true)"

            while IFS= read -r ext || [[ -n "${ext}" ]]; do
                [[ "${ext}" =~ ^[[:space:]]*# ]] && continue
                [[ -z "${ext// }" ]] && continue

                if echo "${CURRENT_EXTS}" | grep -qx "${ext}"; then
                    log_skip "${ext}"
                else
                    log_install "${ext}"
                    spin_task "Installing extension ${ext}" code --install-extension "${ext}" --force
                fi
            done < "${EXT_FILE}"
        fi
    fi

    log_footer
}

# ==============================================================================
# 📐 TEMPLATES: Pipeline Orchestration
# ==============================================================================
print_banner() {
    clear 2>/dev/null || true
    echo -e "${COLOR_CYAN}╭─────────────────────────────────────────────────────────────╮${COLOR_NC}"
    echo -e "${COLOR_CYAN}│  ${COLOR_GREEN}${GLYPH_MANJARO}${COLOR_WHITE} MANJARO GNOME // DOTFILES SETUP PIPELINE                ${COLOR_CYAN}│${COLOR_NC}"
    echo -e "${COLOR_CYAN}│  ${COLOR_DIM}Modular • Idempotent • Developer Environment               ${COLOR_CYAN}│${COLOR_NC}"
    echo -e "${COLOR_CYAN}╰─────────────────────────────────────────────────────────────╯${COLOR_NC}"
    echo -e "  ${COLOR_CYAN}➜${COLOR_NC} ${COLOR_WHITE}Source Directory :${COLOR_NC} ${COLOR_DIM}${DOTFILES_DIR}${COLOR_NC}"
    echo -e "  ${COLOR_CYAN}➜${COLOR_NC} ${COLOR_WHITE}Backup Directory :${COLOR_NC} ${COLOR_DIM}${BACKUP_DIR}${COLOR_NC}"
    if [[ "${DRY_RUN}" = true ]]; then
        echo -e "  ${COLOR_YELLOW}${GLYPH_WARN} Mode             :${COLOR_YELLOW} DRY-RUN (Simulating execution)${COLOR_NC}"
    fi
}

run_pipeline() {
    print_banner

    if [[ "${SKIP_PACKAGES}" = false ]]; then
        phase_a_core_and_aur
        phase_b_fonts
    else
        log_header "${GLYPH_PACKAGE}  Phase A & B: Packages (Bypassed)"
        log_info "Package installation bypassed (--skip-packages active)."
        log_footer
    fi

    phase_c_macos_shortcuts
    phase_d_shell_and_symlinks

    echo -e "\n${COLOR_GREEN}╭─────────────────────────────────────────────────────────────╮${COLOR_NC}"
    echo -e "${COLOR_GREEN}│  ${GLYPH_SPARKLE} Pipeline execution completed successfully!              ${COLOR_GREEN}│${COLOR_NC}"
    echo -e "${COLOR_GREEN}│  ${GLYPH_CHECK} All configurations are verified and symlinked.          ${COLOR_GREEN}│${COLOR_NC}"
    echo -e "${COLOR_GREEN}│  ${COLOR_WHITE}➜ Apply shell changes:${COLOR_NC} ${COLOR_YELLOW}source ~/.zshrc                     ${COLOR_GREEN}│${COLOR_NC}"
    echo -e "${COLOR_GREEN}╰─────────────────────────────────────────────────────────────╯${COLOR_NC}\n"
}

# ==============================================================================
# 📄 PAGES: CLI Entrypoint & Flags
# ==============================================================================
print_help() {
    cat << HELP_TEXT
Usage: ./setup.sh [OPTIONS]

Animated Idempotent Setup Pipeline for Manjaro GNOME Dotfiles.

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
