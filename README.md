# 🐧 Manjaro GNOME Dotfiles

> Modular, aesthetic, and high-productivity dotfiles optimized for Full-Stack Developers (React/TypeScript, Ruby on Rails, Laravel/PHP). Dikonfigurasi dan dioptimalkan secara native khusus untuk **Manjaro Linux (GNOME Desktop / Wayland)**.

---

## 📑 Daftar Isi

- [Fitur Utama](#-fitur-utama)
- [Spesifikasi Lingkungan](#-spesifikasi-lingkungan)
- [Struktur Repositori](#-struktur-repositori)
- [Panduan Instalasi Cepat](#-panduan-instalasi-cepat)
- [Arsitektur Pipeline Script (`setup.sh`)](#-arsitektur-pipeline-script-setupsh)
- [Pintasan Keyboard Bergaya macOS](#-pintasan-keyboard-bergaya-macos-gnome)
- [Konfigurasi ZSH & Daftar Alias](#-konfigurasi-zsh--daftar-alias)
- [Penyesuaian Khusus Manjaro GNOME Desktop](#-penyesuaian-khusus-manjaro-gnome-desktop)
- [Pemetaan Paket (Mint / APT → Manjaro / Pacman)](#-pemetaan-paket-mint--apt--manjaro--pacman)
- [Manajemen Backup & Rollback](#-manajemen-backup--rollback)
- [Pemecahan Masalah (Troubleshooting)](#-pemecahan-masalah-troubleshooting)
- [Kontributor & Lisensi](#-kontributor--lisensi)

---

## ✨ Fitur Utama

- 🎨 **Modern Glassmorphism & UI Aesthetic**:
  - **Kitty Terminal**: Transparan (opacity 0.85), Wayland native, clipboard control terintegrasi, dan pembersihan spasi otomatis (_smart trailing spaces_).
  - **Starship Prompt**: Skema warna Crimson dengan logo resmi **Manjaro (` `)**, modul Git, runtime status (Node, Ruby, PHP, Go, Rust), dan path direktori bersih.
  - **VS Code**: Pengaturan modern, tema Solarized/Tokyo Night, font _Fira Code_ dengan ligatures aktif, serta formatting terintegrasi.
- ⚡ **ZSH Teroptimasi & Cepat**:
  - **Defensive Bracketed Paste**: Menghilangkan polusi karakter escape sequence `^[[200~` saat copy-paste teks ke terminal.
  - **Smart Navigation `cd`**: Otomatis mendeteksi folder tanpa memedulikan huruf besar/kecil (_case-insensitive_ misal `cd lab` -> `cd Lab`) dan fallback cerdas ke Zoxide (`z`).
  - **Lazy-Loaded NVM**: Startup terminal instan (< 30ms) dengan memuat Node Version Manager hanya saat perintah `nvm` dipanggil pertama kali.
  - **Full-Sync Update**: Perintah `update` menyinkronkan paket resmi Arch/Manjaro, AUR via Yay, dan paket Flatpak sekaligus.
- 🍎 **macOS-Style Shortcuts di GNOME**:
  - Integrasi pintasan tangkapan layar ala Mac (`Super+Shift+3`, `Super+Shift+4`, `Super+Shift+5`) serta manajemen jendela (`Super+Q`, `Super+H`).
- 🛡️ **Safe, Idempotent & Non-Destructive**:
  - Backup otomatis bertanggal ke `~/.dotfiles_backup/<timestamp>` sebelum menimpa konfigurasi lama.
  - Symlink idempotent (`ln -sf`), aman dijalankan berulang kali tanpa merusak berkas yang sudah ada.
- 📦 **Automated Extension Restore**:
  - Memverifikasi dan memasang 40+ ekstensi VS Code penting dengan pengecekan duplikasi otomatis.

---

## 🖥️ Spesifikasi Lingkungan

| Komponen                | Spesifikasi / Konfigurasi                                                               |
| ----------------------- | --------------------------------------------------------------------------------------- |
| **Distribusi OS**       | Manjaro Linux (Rolling Release, Kernel 6.x / 7.x)                                       |
| **Desktop Environment** | GNOME Shell (Wayland Display Server)                                                    |
| **Shell Utama**         | Zsh + Oh My Zsh (Plugin: git, sudo, npm, fzf-tab, autosuggestions, syntax-highlighting) |
| **Prompt Engine**       | Starship Cross-Shell Prompt (Ikon Manjaro  )                                           |
| **Terminal Emulator**   | Kitty (GPU Accelerated, Wayland Native)                                                 |
| **Editor Utama**        | Visual Studio Code (`visual-studio-code-bin` / `code`)                                  |
| **Font Terminal**       | JetBrainsMono Nerd Font (`ttf-jetbrains-mono-nerd`)                                     |
| **Font Emoji**          | Noto Color Emoji (`noto-fonts-emoji`)                                                   |
| **Font Editor**         | Fira Code (`ttf-fira-code`) dengan ligatures                                            |
| **Clipboard CLI**       | `wl-clipboard` (`wl-copy`, `wl-paste`)                                                  |

---

## 📂 Struktur Repositori

```text
~/dotfiles/ (atau ~/Lab/dotfile_v2/)
├── git/
│   └── .gitconfig          # Identitas Git, default branch main, credential helper
├── kitty/
│   └── kitty.conf          # Konfigurasi Kitty (tema Modern Glassmorphism)
├── package-mapping.md      # Tabel pemetaan dependencies Debian (APT) ke Arch (Pacman/AUR)
├── README.md               # Dokumentasi utama repositori Manjaro GNOME
├── setup.sh                # Master pipeline deployment script (Atomic Design, 4-Phase)
├── shell/
│   ├── .bashrc             # Baseline konfigurasi Bash + NVM hook
│   └── .zshrc              # Zshrc aktif: Smart CD, NVM lazy, Yay/Flatpak sync, dev aliases
├── starship/
│   └── starship.toml       # Tema Starship Modern Crimson (ikon Manjaro  )
└── vscode/
    ├── extensions.list     # Daftar 43 ekstensi aktif VS Code
    ├── keybindings.json    # Shortcut produktivitas VS Code
    ├── settings.json       # Settings UI, linter, formatter, & layout editor
    └── snippets/           # User code snippets (.gitkeep)
```

---

## 🚀 Panduan Instalasi Cepat

### Single-Command Bootstrap

Jalankan satu perintah berikut di terminal Manjaro GNOME Anda untuk mengklon dan mengeksekusi pipeline:

```bash
git clone https://github.com/parikesitad-pm/dotfile_v2.git ~/dotfiles && cd ~/dotfiles && ./setup.sh
```

### Opsi Eksekusi Bertahap

#### 1. Uji Coba Simulasi (Dry-Run)

Pastikan semua dependensi dan target symlink terdeteksi tanpa mengubah file sistem:

```bash
./setup.sh --dry-run
```

#### 2. Eksekusi Pemasangan Penuh

Jalankan script untuk menginstal paket, membuat symlink, mengatur pintasan macOS di GNOME, dan memulihkan ekstensi VS Code:

```bash
./setup.sh
```

---

## ⚙️ Arsitektur Pipeline Script (`setup.sh`)

Script [`setup.sh`](./setup.sh) dibangun dengan prinsip **Atomic Design** yang dibagi ke dalam 5 fase eksekusi:

1. **Phase A: Core Native Apps & AUR Packages**
   - Memverifikasi paket resmi melalui `pacman -Qi`: `base-devel`, `git`, `curl`, `wget`, `btop`, `fastfetch`, `firefox`, `discord`, `zsh`, `zsh-autosuggestions`, `zsh-syntax-highlighting`, `github-cli`, `eza`, `zoxide`, `gnome-keyring`, `libsecret`, `seahorse`, `kitty`, `starship`, `bat`, `fd`, `ripgrep`, `fzf`, `wl-clipboard`.
   - Memverifikasi AUR helper (`yay`), otomatis meng-clone dan membangun dari AUR jika belum ada.
   - Memverifikasi paket AUR: `ulauncher`, `google-chrome`, `visual-studio-code-bin`, `spotify`.
   - Mengaktifkan daemon service Ulauncher (`systemctl --user enable --now ulauncher`).
2. **Phase B: Developer Stacks & Runtimes (React/TS, Laravel, Rails, DBs)**
   - **React / TS & Node.js**: Memasang NVM (`~/.nvm`), package manager modern `yarn` dan `pnpm`.
   - **PHP & Laravel**: Memasang `php`, `php-fpm`, `php-gd`, `php-intl`, `php-sodium`, `php-sqlite`, `php-pgsql`, `composer`, dan `sqlite`.
   - **Ruby on Rails**: Memasang dependensi kompilasi (`libyaml`, `libffi`, `openssl`, `zlib`, `readline`, `gdbm`) serta version manager `rbenv` dan `ruby-build`.
   - **Databases & Cache**: Memasang backend database lokal `postgresql`, `mariadb`, dan `redis`.
3. **Phase C: Fonts Installation & Cache Refresh**
   - Memverifikasi dan memasang paket font lengkap: `ttf-jetbrains-mono-nerd`, `ttf-firacode-nerd`, `ttf-fira-code`, `ttf-jetbrains-mono`, `ttf-nerd-fonts-symbols`, dan `noto-fonts-emoji`.
   - Memperbarui cache font sistem via `fc-cache -f`.
4. **Phase D: macOS-style Shortcuts & GNOME Performance Tweaks**
   - Menerapkan pintasan tangkapan layar dan window management via `gsettings`.
   - Menonaktifkan animasi antarmuka GNOME untuk respon instan.
   - Me-mask service tracker miner yang boros CPU/RAM.
5. **Phase E: Shell Normalization, Symlinks & Extension Restore**
   - Melakukan pencadangan non-destruktif ke `~/.dotfiles_backup/<timestamp>`.
   - Menautkan `shell/.zshrc`, `shell/.bashrc`, `starship/starship.toml`, `kitty/`, `git/.gitconfig`, dan konfigurasi VS Code.
   - Memasang ekstensi VS Code dari `vscode/extensions.list` dengan pengecekan agar tidak mengulang instalasi yang sudah ada.

### Flag Modular yang Tersedia

```bash
# Simulasi dry-run tanpa mengubah sistem
./setup.sh --dry-run

# Mode cepat tanpa jeda visual lazyload
./setup.sh --fast

# Lewati instalasi paket apa pun (Core, Dev, Fonts)
./setup.sh --skip-packages

# Lewati instalasi stack developer (Node, Laravel, Rails, DBs)
./setup.sh --skip-dev

# Lewati instalasi ekstensi VS Code
./setup.sh --skip-extensions

# Lewati pengaturan pintasan GNOME
./setup.sh --skip-shortcuts

# Tampilkan panduan flag
./setup.sh --help
```

---

## 🍎 Pintasan Keyboard Bergaya macOS (GNOME)

Pintasan berikut otomatis dikonfigurasi saat pipeline dijalankan:

| Shortcut            | Fungsi Desktop GNOME                                  | Skema GSettings                                  |
| ------------------- | ----------------------------------------------------- | ------------------------------------------------ |
| `Super + Shift + 3` | Tangkapan layar layar penuh (_Fullscreen Screenshot_) | `org.gnome.shell.keybindings screenshot`         |
| `Super + Shift + 4` | Tangkapan layar jendela/area tertentu                 | `org.gnome.shell.keybindings screenshot-window`  |
| `Super + Shift + 5` | Buka antarmuka Screenshot & Screen Recording          | `org.gnome.shell.keybindings show-screenshot-ui` |
| `Super + Q`         | Tutup jendela aktif (_Close Window_)                  | `org.gnome.desktop.wm.keybindings close`         |
| `Super + H`         | Minimalkan jendela aktif (_Minimize Window_)          | `org.gnome.desktop.wm.keybindings minimize`      |

---

## ⚡ Konfigurasi ZSH & Daftar Alias

File [`.zshrc`](./shell/.zshrc) memuat utilitas dan alias produktivitas harian:

### 📦 Manajemen Paket & Pembaruan Sistem

| Alias / Fungsi   | Perintah Asli                       | Deskripsi                                               |
| ---------------- | ----------------------------------- | ------------------------------------------------------- |
| `update`         | Fungsi `update`                     | Sinkronisasi penuh paket Pacman, AUR (Yay), dan Flatpak |
| `install <pkg>`  | `yay -S --needed --noconfirm <pkg>` | Pasang paket resmi atau AUR tanpa konfirmasi            |
| `remove <pkg>`   | `yay -Rns <pkg>`                    | Hapus paket beserta seluruh dependensinya               |
| `search <query>` | `yay -Ss <query>`                   | Cari paket di repositori resmi dan AUR                  |
| `autoremove`     | Fungsi `pacclean`                   | Bersihkan orphaned packages dengan aman tanpa error     |

### 🪟 GNOME Session & Desktop Controls

| Alias                  | Perintah Asli                             | Deskripsi                                 |
| ---------------------- | ----------------------------------------- | ----------------------------------------- |
| `keluar`               | `gnome-session-quit --logout --no-prompt` | Keluar dari sesi GNOME                    |
| `lock`                 | `loginctl lock-session`                   | Kunci layar desktop                       |
| `ribut`                | `sudo reboot`                             | Restart komputer                          |
| `matikan` / `shutdown` | `sudo poweroff`                           | Matikan komputer                          |
| `gnome-ver`            | `gnome-shell --version`                   | Cek versi GNOME Shell                     |
| `copy`                 | `wl-copy`                                 | Salin teks ke clipboard Wayland           |
| `paste`                | `wl-paste`                                | Tempel teks dari clipboard Wayland        |
| `open <file/url>`      | `xdg-open <file/url>`                     | Buka file atau URL dengan aplikasi bawaan |

### 🔍 Navigasi & File CLI

| Alias          | Perintah Asli        | Deskripsi                                              |
| -------------- | -------------------- | ------------------------------------------------------ |
| `ls`           | `eza --icons`        | Tampilan berkas modern dengan ikon                     |
| `ll`           | `eza -la --icons`    | Daftar detail berkas lengkap                           |
| `la`           | `eza --icons -a`     | Tampilan berkas tersembunyi (_hidden files_)           |
| `tree`         | `eza --tree --icons` | Tampilan visual pohon hierarki direktori               |
| `cd <dir>`     | Fungsi pintar `cd`   | Case-insensitive folder jump dengan fallback ke Zoxide |
| `cat <file>`   | `bat <file>`         | Syntax highlighting file viewer                        |
| `find <query>` | `fd <query>`         | Pencarian berkas ultra cepat                           |
| `grep <query>` | `rg <query>`         | Pencarian teks dalam berkas via Ripgrep                |
| `c` / `.c`     | `code` / `code .`    | Buka Visual Studio Code                                |
| `clone <url>`  | `git clone <url>`    | Klon repositori git                                    |

### ⚛️ Developer Stacks (React/TS, Rails, Laravel)

| Alias                | Perintah Asli                              | Ekosistem              |
| -------------------- | ------------------------------------------ | ---------------------- |
| `ys` / `yd` / `yb`   | `yarn start` / `yarn dev` / `yarn build`   | Yarn                   |
| `pd` / `pb`          | `pnpm dev` / `pnpm build`                  | PNPM                   |
| `allahuakbar`        | `npm run dev`                              | NPM Run Dev            |
| `rs` / `rc` / `rd`   | `bin/rails server` / `console` / `bin/dev` | Ruby on Rails          |
| `dbm` / `dbr`        | `bin/rails db:migrate` / `rollback`        | Rails DB               |
| `b`                  | `bundle exec`                              | Bundler                |
| `bismillah`          | `bin/dev`                                  | Rails Dev Runner       |
| `astagrifullah`      | `rails console`                            | Rails REPL             |
| `pa` / `pas` / `pam` | `php artisan` / `serve` / `migrate`        | Laravel                |
| `fresh`              | `php artisan migrate:fresh --seed`         | Laravel Refresh & Seed |
| `tinker`             | `php artisan tinker`                       | Laravel REPL           |
| `forg`               | `cd project/forge/forge`                   | Quick Project Jump     |
| `dev`                | `cd project`                               | Quick Project Jump     |

---

## 🪟 Penyesuaian Khusus Manjaro GNOME Desktop

### 1. Ekstensi GNOME yang Direkomendasikan

1. **Dash to Dock**:
   - Memindahkan dock ke bawah atau kiri dengan gaya macOS, auto-hide, dan custom opacity:
     ```bash
     sudo pacman -S gnome-shell-extension-dash-to-dock
     ```
2. **Blur my Shell**:
   - Memberikan efek glassmorphism/blur transparan pada panel atas, dock, dan app grid yang selaras dengan Kitty Terminal:
     ```bash
     yay -S gnome-shell-extension-blur-my-shell
     ```
3. **AppIndicator and KStatusNotifierItem Support**:
   - Menampilkan ikon tray aplikasi di top bar (Discord, Spotify, VS Code):
     ```bash
     sudo pacman -S gnome-shell-extension-appindicator
     ```

### 2. Navigasi Gestures Bawaan GNOME Wayland

- **Swipe 3 jari ke atas**: Buka Overview & Application Grid.
- **Swipe 3 jari ke kiri/kanan**: Berpindah antar Workspace secara instan.
- **Pinch 2 jari**: Zoom in/out pada aplikasi yang didukung.

---

## 🔄 Pemetaan Paket (Mint / APT → Manjaro / Pacman)

| Utility      | Linux Mint (APT)                 | Manjaro (Pacman / AUR)          | Catatan Binary                                      |
| ------------ | -------------------------------- | ------------------------------- | --------------------------------------------------- |
| Modern `ls`  | `apt install eza`                | `sudo pacman -S eza`            | Binary: `eza`                                       |
| Fast `cat`   | `apt install bat` (`batcat`)     | `sudo pacman -S bat`            | **Di Manjaro binary adalah `bat` (bukan `batcat`)** |
| Fast `find`  | `apt install fd-find` (`fdfind`) | `sudo pacman -S fd`             | **Di Manjaro binary adalah `fd` (bukan `fdfind`)**  |
| Code Search  | `apt install ripgrep`            | `sudo pacman -S ripgrep`        | Binary: `rg`                                        |
| Fuzzy Finder | `apt install fzf`                | `sudo pacman -S fzf`            | Scripts di `/usr/share/fzf/`                        |
| Prompt       | Cargo / Homebrew                 | `sudo pacman -S starship`       | Konfigurasi di `~/.config/starship.toml`            |
| Terminal     | `apt install kitty`              | `sudo pacman -S kitty`          | GPU accelerated, Wayland native                     |
| VS Code      | DEB package                      | `yay -S visual-studio-code-bin` | Official binary Microsoft                           |
| Clipboard    | `xclip`                          | `sudo pacman -S wl-clipboard`   | `wl-copy` & `wl-paste` native Wayland               |

---

## ⏪ Manajemen Backup & Rollback

Setiap kali `setup.sh` mendeteksi file konfigurasi lama di sistem pengguna yang belum berupa symlink ke repositori ini:

1. File lama **tidak langsung ditimpa**, melainkan dicadangkan ke direktori terpusat bertanggal:
   ```text
   ~/.dotfiles_backup/YYYYMMDD_HHMMSS/
   ```
2. Jaminan idempotensi penuh: Jika file target sudah merupakan symlink aktif ke repositori ini, script akan memverifikasi dan melewatinya tanpa melakukan modifikasi atau pembuatan backup redundan.
3. Untuk mengembalikan konfigurasi lama jika dibutuhkan:
   ```bash
   # Contoh rollback .zshrc dari direktori cadangan:
   rm ~/.zshrc
   cp -a ~/.dotfiles_backup/<timestamp>/.zshrc ~/.zshrc
   ```

---

## 🔧 Pemecahan Masalah (Troubleshooting)

### 1. Database Pacman Terkunci (`/var/lib/pacman/db.lck`)

Jika proses instalasi pacman terhenti mendadak:

```bash
sudo rm /var/lib/pacman/db.lck
```

### 2. Font Icon / Glyph Kotak-Kotak di Kitty atau Starship

Pastikan Nerd Fonts sudah terpasang dan cache font diperbarui:

```bash
sudo pacman -S --needed ttf-jetbrains-mono-nerd noto-fonts-emoji ttf-fira-code
fc-cache -fv
```

### 3. FZF Keybindings (Ctrl+R / Ctrl+T) Belum Aktif

Pastikan paket `fzf` sudah terpasang via pacman:

```bash
sudo pacman -S fzf
source ~/.zshrc
```

---

## 👤 Pengembang

- **Author**: `parikesitad-pm`
- **Role**: Project Analyst, QA Tester & Full-Stack Developer
- **Target OS**: Manjaro Linux (GNOME Edition)
- **Theme Concept**: Modern Glassmorphism & macOS-style Productivity

---

_Happy Hacking on Manjaro GNOME!_ 🚀
