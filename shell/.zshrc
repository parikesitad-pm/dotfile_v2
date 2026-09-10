# ==============================================================================
# GUNDAM GLASS GNOME - ZSH CONFIGURATION (.zshrc)
# Developer: parikesitad-pm (Project Analyst, QA Tester & Full-Stack Developer)
# Optimized for: Manjaro Linux (GNOME Desktop / Wayland)
# Tech Stack: React/TS, Ruby on Rails, Laravel/PHP
# ==============================================================================

# ================================
# PATH (CLEAN & SINGLE SOURCE)
# ================================
export PATH="$HOME/.local/bin:$HOME/.spicetify:$HOME/.rbenv/bin:$HOME/.composer/vendor/bin:/usr/local/bin:$PATH"

# ================================
# OH MY ZSH SETUP
# ================================
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""

DISABLE_UNTRACKED_FILES_DIRTY="true"

plugins=(
  git
  sudo
  npm
  archlinux
  zsh-autosuggestions
  zsh-completions
  zsh-syntax-highlighting
  fzf-tab
)

[ -f "$ZSH/oh-my-zsh.sh" ] && source "$ZSH/oh-my-zsh.sh"

# ==============================================================================
# ARCH-NATIVE PLUGINS (CONDITIONAL SOURCE)
# ==============================================================================
[ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ] && source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
[ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ] && source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# ================================
# MAN PAGE COLORS
# ================================
autoload -U colors && colors
export LESS_TERMCAP_mb=$'\E[1;31m'
export LESS_TERMCAP_md=$'\E[1;36m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[1;44;33m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[1;32m'

# ================================
# HISTORY & BEHAVIOR
# ================================
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_ALL_DUPS
setopt SHARE_HISTORY
setopt AUTO_CD
setopt CORRECT
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT

# ================================
# BRACKETED PASTE HANDLING
# ================================
autoload -Uz bracketed-paste-magic
zle -N bracketed-paste bracketed-paste-magic
unset zle_bracketed_paste

# ================================
# ALIASES
# ================================

# File & Navigation (Eza Modern Replacements)
alias ls="eza --icons"
alias ll="eza -la --icons"
alias la="eza --icons -a"
alias tree="eza --tree --icons"
alias cd="z"

# File View & Search (Arch / Manjaro Native Binaries)
if command -v bat &>/dev/null; then
  alias cat="bat"
elif command -v batcat &>/dev/null; then
  alias cat="batcat"
fi
alias find="fd"
alias grep="rg"

# VS Code
alias c="code"
alias .c="code ."

# ================================
# SYSTEM SHORTCUTS (MANJARO & GNOME)
# ================================

# Pacman Package Management
alias update="sudo pacman -Syu"
alias upgrade="sudo pacman -Syu"
alias install="sudo pacman -S"
alias remove="sudo pacman -Rns"
alias search="pacman -Ss"

# Pamac & AUR (Yay) Helpers
alias pupdate="pamac update"
alias pinstall="pamac install"
alias yupdate="yay -Syu"
alias yinstall="yay -S"
alias ysearch="yay -Ss"

# Safe Clean Orphan Packages (Autoremove)
pacclean() {
  local orphans
  orphans=($(pacman -Qtdq 2>/dev/null))
  if [ ${#orphans[@]} -gt 0 ]; then
    sudo pacman -Rns "${orphans[@]}"
  else
    echo "✨ No orphaned packages found."
  fi
}
alias autoremove="pacclean"

# Power & GNOME Session Controls
alias ribut="sudo reboot"
alias matikan="sudo poweroff"
alias shutdown="sudo poweroff"
alias logout="gnome-session-quit --logout --no-prompt"
alias lock="loginctl lock-session"
alias gnome-ver="gnome-shell --version"

# Clipboard Support (Wayland / X11) & Utilities
if command -v wl-copy &>/dev/null; then
  alias copy="wl-copy"
  alias paste="wl-paste"
elif command -v xclip &>/dev/null; then
  alias copy="xclip -selection clipboard"
  alias paste="xclip -selection clipboard -o"
fi
alias open="xdg-open"

# Safety
alias rm="rm -i"
alias cp="cp -i"
alias mv="mv -i"
alias hapus="rm -rf"

# Misc
alias cls="clear"
alias spa="spicetify apply"
alias sba="spicetify backup apply"
alias sup="spicetify update"

# --------------------------------
# ⚛️ REACT / JS / TS (PNPM & YARN)
# --------------------------------
alias ys="yarn start"
alias yd="yarn dev"
alias yb="yarn build"
alias pd="pnpm dev"
alias pb="pnpm build"

# --------------------------------
# 🛤️ RUBY ON RAILS
# --------------------------------
alias rs="bin/rails server"
alias rc="bin/rails console"
alias rd="bin/dev"
alias dbm="bin/rails db:migrate"
alias dbr="bin/rails db:rollback"
alias b="bundle exec"
alias rails="nocorrect rails"
alias bin/rails="nocorrect bin/rails"
alias bismillah="bin/dev"
alias astagrifullah="rails console"
alias allahuakbar="npm run dev"

# --------------------------------
# 🐘 LARAVEL
# --------------------------------
alias pa="php artisan"
alias pas="php artisan serve"
alias pam="php artisan migrate"
alias fresh="php artisan migrate:fresh --seed"
alias tinker="php artisan tinker"

# Custom Folder Navigation
alias forg="cd project/forge/forge"
alias dev="cd project"

# ================================
# FZF & FZF-TAB
# ================================
# Arch / Manjaro system-wide package or git clone fallback
if [ -f ~/.fzf.zsh ]; then
  source ~/.fzf.zsh
elif [ -d /usr/share/fzf ]; then
  [ -f /usr/share/fzf/key-bindings.zsh ] && source /usr/share/fzf/key-bindings.zsh
  [ -f /usr/share/fzf/completion.zsh ] && source /usr/share/fzf/completion.zsh
fi

zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza --icons --color=always $realpath'
zstyle ':fzf-tab:*' switch-group ',' '.'

# ================================
# TOOL HOOKS & RUNTIMES
# ================================
eval "$(starship init zsh)"
eval "$(zoxide init zsh)"
command -v direnv >/dev/null 2>&1 && eval "$(direnv hook zsh)"
command -v rbenv >/dev/null 2>&1 && eval "$(rbenv init - zsh)"

# NVM Setup
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"

# ================================
# CUSTOM FUNCTIONS
# ================================
flat() {
  flatpak install flathub "$@"
}
