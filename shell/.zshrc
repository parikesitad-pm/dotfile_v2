# ==============================================================================
# GUNDAM GLASS XFCE - ZSH CONFIGURATION (.zshrc)
# Developer: parikesitad-pm (Project Analyst, QA Tester & Full-Stack Developer)
# Optimized for: Linux Mint XFCE | ReactJS & Ruby on Rails Developer Workflow
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
  zsh-autosuggestions
  zsh-completions
  zsh-syntax-highlighting
  fzf-tab
)

[ -f "$ZSH/oh-my-zsh.sh" ] && source "$ZSH/oh-my-zsh.sh"

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
# ALIASES
# ================================

# File & Navigation
alias ls="eza --icons"
alias ll="eza --icons -lah"
alias la="eza --icons -a"
alias tree="eza --icons --tree"
alias cd="z"

# File View & Search (Fix Ubuntu/Debian Binary Name)
alias cat="batcat"
alias find="fd"
alias grep="rg"

# VS Code
alias c="code"
alias .c="code ."

# System Shortcuts (Perbaikan Linux Mint XFCE)
alias update="sudo apt update && sudo apt upgrade -y"
alias upgrade="sudo apt update && sudo apt upgrade -y"
alias install="sudo apt install -y"
alias remove="sudo apt remove -y"
alias autoremove="sudo apt autoremove -y"
alias ribut="sudo reboot"
alias matikan="sudo poweroff"
alias shutdown="sudo poweroff"
alias logout="xfce4-session-logout --logout"

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
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza --icons --color=always $realpath'
zstyle ':fzf-tab:*' switch-group ',' '.'

# ================================
# TOOL HOOKS & RUNTIMES
# ================================
command -v starship >/dev/null 2>&1 && eval "$(starship init zsh)"
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init zsh)"
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
