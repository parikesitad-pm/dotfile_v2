export PATH="$HOME/.local/bin:$HOME/.spicetify:$HOME/.rbenv/bin:$HOME/.composer/vendor/bin:/usr/local/bin:$PATH"

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""

DISABLE_UNTRACKED_FILES_DIRTY="true"

plugins=(
  git
  sudo
  npm
  fzf-tab
)

# ── zstyle SEBELUM source OMZ ────────────────────────────
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z} m:{A-Z}={a-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza --icons --color=always $realpath'
zstyle ':fzf-tab:*' switch-group ',' '.'

# ── source OMZ ───────────────────────────────────────────
[ -f "$ZSH/oh-my-zsh.sh" ] && source "$ZSH/oh-my-zsh.sh"

# ── compinit + fzf-tab SETELAH OMZ ───────────────────────
autoload -Uz compinit && compinit

autoload -U colors && colors
export LESS_TERMCAP_mb=$'\E[1;31m'
export LESS_TERMCAP_md=$'\E[1;36m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[1;44;33m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[1;32m'

HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_ALL_DUPS
setopt SHARE_HISTORY
setopt AUTO_CD
setopt CORRECT
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT
setopt NO_CASE_GLOB

autoload -Uz bracketed-paste-magic
zle -N bracketed-paste bracketed-paste-magic
unset zle_bracketed_paste

# ── Aliases: ls ──────────────────────────────────────────
alias ls="eza --icons"
alias ll="eza -la --icons"
alias la="eza --icons -a"
alias tree="eza --tree --icons"

# ── Aliases: core utils ───────────────────────────────────
if command -v bat &>/dev/null; then
  alias cat="bat"
fi
command -v fd &>/dev/null && alias find="fd"
command -v rg &>/dev/null && alias grep="rg"

# ── Aliases: editor ───────────────────────────────────────
alias c="code"
alias .c="code ."

# ── Aliases: package manager ──────────────────────────────
update() {
  echo "📦 Updating Arch/Manjaro & AUR packages..."
  yay -Syu --noconfirm

  if command -v flatpak &>/dev/null; then
    echo "📦 Updating Flatpaks..."
    flatpak update -y
  fi

  echo "✨ All systems up to date!"
}

alias install="yay -S --needed --noconfirm"
alias remove="yay -Rns"
alias search="yay -Ss"

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

# ── Aliases: system ───────────────────────────────────────
alias ribut="sudo reboot"
alias matikan="sudo poweroff"
alias shutdown="sudo poweroff"
alias keluar="gnome-session-quit --logout --no-prompt"
alias lock="loginctl lock-session"
alias gnome-ver="gnome-shell --version"

# ── Aliases: clipboard ────────────────────────────────────
if command -v wl-copy &>/dev/null; then
  alias copy="wl-copy"
  alias paste="wl-paste"
elif command -v xclip &>/dev/null; then
  alias copy="xclip -selection clipboard"
  alias paste="xclip -selection clipboard -o"
fi
alias open="xdg-open"

# ── Aliases: file safety ──────────────────────────────────
alias rm="rm -i"
alias cp="cp -i"
alias mv="mv -i"
alias hapus="sudo rm -rf"

# ── Aliases: misc ─────────────────────────────────────────
alias cls="clear"
alias spa="spicetify apply"
alias sba="spicetify backup apply"
alias sup="spicetify update"

# ── Aliases: JS/TS dev ────────────────────────────────────
alias ys="yarn start"
alias yd="yarn dev"
alias yb="yarn build"
alias pd="pnpm dev"
alias pb="pnpm build"
alias allahuakbar="npm run dev"

# ── Aliases: Rails ────────────────────────────────────────
alias rs="bin/rails server"
alias rc="bin/rails console"
alias rd="bin/dev"
alias dbm="bin/rails db:migrate"
alias dbr="bin/rails db:rollback"
alias b="bundle exec"
alias rails="nocorrect rails"
alias bismillah="bin/dev"
alias astagrifullah="rails console"

# ── Aliases: Laravel ──────────────────────────────────────
alias pa="php artisan"
alias pas="php artisan serve"
alias pam="php artisan migrate"
alias fresh="php artisan migrate:fresh --seed"
alias tinker="php artisan tinker"

# ── Aliases: nav ──────────────────────────────────────────
alias forg="cd project/forge/forge"
alias dev="cd project"

# git
alias clone="git clone"

# ── fzf ───────────────────────────────────────────────────
if [ -f ~/.fzf.zsh ]; then
  source ~/.fzf.zsh
elif [ -d /usr/share/fzf ]; then
  [ -f /usr/share/fzf/key-bindings.zsh ] && source /usr/share/fzf/key-bindings.zsh
  [ -f /usr/share/fzf/completion.zsh ] && source /usr/share/fzf/completion.zsh
fi

# ── Tools init ────────────────────────────────────────────
eval "$(starship init zsh)"
eval "$(zoxide init zsh)"
cd() {
  if [ $# -eq 0 ]; then
    builtin cd ~
    return
  fi

  # 1. Coba path aslinya dulu
  if builtin cd "$@" 2>/dev/null; then
    return
  fi

  # 2. Cari folder lokal dengan nama yang sama tanpa peduli huruf besar/kecil (lab -> Lab)
  local target=( "$1"*(N/) )
  if [ ${#target[@]} -gt 0 ]; then
    builtin cd "${target[1]}"
    return
  fi

  # 3. Kalau tidak ada di folder saat ini, fallback ke zoxide
  z "$@"
}

command -v direnv >/dev/null 2>&1 && eval "$(direnv hook zsh)"
# command -v rbenv >/dev/null 2>&1 && eval "$(rbenv init - zsh)"

# ── NVM lazy load ─────────────────────────────────────────
export NVM_DIR="$HOME/.nvm"
nvm() {
  unset -f nvm
  [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"
  nvm "$@"
}

# ── Plugins ───────────────────────────────────────────────
[ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ] && \
  source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
[ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ] && \
  source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# ── Flatpak helper ────────────────────────────────────────
flat() {
  flatpak install flathub "$@"
}
