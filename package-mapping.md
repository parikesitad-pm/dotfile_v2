# Pemetaan Paket: Linux Mint (Debian/Ubuntu) ke Manjaro / Arch Linux

Dokumen ini memetakan toolchain, CLI utility, font, dan aplikasi aktif dari Linux Mint XFCE ke padanannya di Manjaro GNOME (Arch-based) via `pacman` atau `yay` (AUR).

---

## 1. Shell & CLI Utilities

| Mint (APT / Manual) | Manjaro / Arch (Pacman / AUR) | Catatan Perubahan & Integrasi |
|---|---|---|
| `zsh` | `sudo pacman -S zsh` | Shell interaktif utama |
| `kitty` | `sudo pacman -S kitty` | Terminal emulator GPU accelerated |
| `starship` | `sudo pacman -S starship` | Prompt engine (hook: `starship init zsh`) |
| `bat` (`batcat`) | `sudo pacman -S bat` | Di Arch bernama binary `bat` (bukan `batcat`) |
| `eza` | `sudo pacman -S eza` | Modern replacement untuk `ls` |
| `ripgrep` | `sudo pacman -S ripgrep` | Command `rg` |
| `fd-find` (`fdfind`) | `sudo pacman -S fd` | Di Arch bernama binary `fd` (bukan `fdfind`) |
| `zoxide` | `sudo pacman -S zoxide` | Smarter `cd` command |
| `fzf` | `sudo pacman -S fzf` | Fuzzy finder CLI |
| `fastfetch` | `sudo pacman -S fastfetch` | System info viewer |
| `git`, `gh` | `sudo pacman -S git github-cli` | Git & GitHub CLI |
| `curl`, `wget`, `jq` | `sudo pacman -S curl wget jq` | HTTP & JSON tools |

---

## 2. Fonts

| Mint (Manual / PPA) | Manjaro / Arch (Pacman) | Penggunaan |
|---|---|---|
| JetBrainsMono Nerd Font | `sudo pacman -S ttf-jetbrains-mono-nerd` | Digunakan oleh Kitty & Starship |
| Fira Code | `sudo pacman -S ttf-fira-code` | Digunakan oleh VS Code |

---

## 3. Editor & IDE

| Mint | Manjaro / Arch (AUR / Pacman) | Catatan |
|---|---|---|
| `code` (Official VS Code) | `yay -S visual-studio-code-bin` | Official binary Microsoft dari AUR |
| `code-oss` (Open Source) | `sudo pacman -S code` | Varian OSS dari repo resmi Arch/Manjaro |
| `kate` | `sudo pacman -S kate` | Editor teks KDE |

---

## 4. Development Runtimes & Database

| Mint | Manjaro / Arch | Rekomendasi Instalasi |
|---|---|---|
| Node.js / NVM | `curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh \| bash` | NVM via script resmi agar kompatibel dengan `.zshrc` |
| `yarn`, `pnpm` | `sudo pacman -S yarn pnpm` | JS package managers |
| Ruby (`rbenv`) | `yay -S rbenv ruby-build` | Atau clone rbenv ke `~/.rbenv` |
| PHP 8.x + Extensions | `sudo pacman -S php php-fpm php-gd php-intl php-sodium php-sqlite` | Web backend stack |
| Composer | `sudo pacman -S composer` | PHP package manager |
| PostgreSQL | `sudo pacman -S postgresql` | `sudo -u postgres initdb -D /var/lib/postgres/data` |
| MariaDB | `sudo pacman -S mariadb` | `mariadb-install-db --user=mysql --basedir=/usr --datadir=/var/lib/mysql` |
| Redis | `sudo pacman -S redis` | Cache backend |

---

## 5. GUI & Desktop Integrations (GNOME)

| Komponen XFCE | Padanan di Manjaro GNOME | Keterangan |
|---|---|---|
| `plank` (Dock) | Ekstensi **Dash to Dock** (`gnome-shell-extension-dash-to-dock`) | Mengintegrasikan panel/dock native GNOME |
| `touchegg` (Touchpad) | **Native GNOME Gestures** (Wayland) | GNOME memiliki navigasi multi-finger 1:1 bawaan |
| `ulauncher` | `yay -S ulauncher` | Application launcher |
| `xfce4-session-logout` | `gnome-session-quit --logout` | Perintah logout native GNOME |
| Discord (`Legcord`) | `flatpak install flathub app.legcord.Legcord` | Client Discord via Flatpak |
| Spotify | `flatpak install flathub com.spotify.Client` | Streaming musik via Flatpak |
