# 🛸 Gundam 00 // Celestial Being Dotfiles (Manjaro GNOME Edition)

> Modular, aesthetic, and high-productivity dotfiles optimized for Full-Stack Developers (React/TypeScript, Ruby on Rails, Laravel/PHP). Dikonfigurasi dan dioptimalkan secara native khusus untuk **Manjaro Linux (GNOME Desktop / Wayland)**.

---

## 📑 Daftar Isi

- [Fitur Utama](#-fitur-utama)
- [Spesifikasi Lingkungan](#-spesifikasi-lingkungan)
- [Struktur Repositori](#-struktur-repositori)
- [Panduan Instalasi Cepat](#-panduan-instalasi-cepat)
- [Opsi & Flag Script (`setup.sh`)](#-opsi--flag-script-setupsh)
- [Langkah Pasca Instalasi (Post-Install)](#-langkah-pasca-instalasi-post-install)
- [Konfigurasi ZSH & Daftar Alias](#-konfigurasi-zsh--daftar-alias)
- [Penyesuaian Khusus Manjaro GNOME Desktop](#-penyesuaian-khusus-manjaro-gnome-desktop)
- [Pemetaan Paket (Mint / APT → Manjaro / Pacman)](#-pemetaan-paket-mint--apt--manjaro--pacman)
- [Manajemen Backup & Rollback](#-manajemen-backup--rollback)
- [Pemecahan Masalah (Troubleshooting)](#-pemecahan-masalah-troubleshooting)
- [Kontributor & Lisensi](#-kontributor--lisensi)

---

## ✨ Fitur Utama

- 🎨 **Gundam 00 "Celestial Being" Aesthetic**:
  - **Kitty Terminal**: Glassmorphism transparan (opacity 0.85), custom GN-drive/Trans-AM palette, slanted powerline tabs, rendering Wayland native.
  - **Starship Prompt**: Skema warna Trans-AM merah/crimson dengan logo resmi **Manjaro (` `)**, modul status Git, deteksi runtime (Node, Ruby, PHP, Go, Rust), dan path direktori bersih.
  - **VS Code**: Pengaturan UI modern, font *Fira Code* dengan ligatures aktif, dan formatting terintegrasi (Prettier, ESLint, Intelephense, Blade, Ruby LSP).
- ⚡ **Arch / Manjaro Native**:
  - Dioptimalkan untuk binary resmi Arch Linux (`bat`, `fd`, `rg`, `eza`, `zoxide`, `fzf`).
  - Integrasi lengkap package manager: `pacman`, `pamac`, dan AUR (`yay`).
  - Fungsi otomatis pembersihan paket yatim (*orphans*): `autoremove` / `pacclean`.
- 🪟 **GNOME Desktop & Wayland Ready**:
  - Integrasi session GNOME native (`logout`, `lock`, `gnome-ver`).
  - Dukungan clipboard Wayland via `wl-clipboard` (`copy` & `paste` langsung dari terminal).
- 🛡️ **Safe & Non-Destructive Deployment**:
  - Backup bertanggal otomatis (`.bak.<timestamp>`) sebelum menimpa file konfigurasi.
  - Symlink idempotent (`ln -sfn`), aman dijalankan ulang sewaktu-waktu.
- 📦 **Automated Extension Restore**:
  - Otomatis memasang kembali 40+ ekstensi VS Code penting dalam satu langkah.

---

## 🖥️ Spesifikasi Lingkungan

| Komponen | Spesifikasi / Konfigurasi |
|---|---|
| **Distribusi OS** | Manjaro Linux (Rolling Release, Kernel Linux 6.x / 7.x) |
| **Desktop Environment** | GNOME Shell (Wayland Display Server) |
| **Shell Utama** | Zsh + Oh My Zsh (Plugin: git, sudo, npm, archlinux, fzf-tab) |
| **Prompt Engine** | Starship Cross-Shell Prompt (Tema Trans-AM GN Particles) |
| **Terminal Emulator** | Kitty (GPU Accelerated, Wayland Native) |
| **Editor Utama** | Visual Studio Code (`code` / `visual-studio-code-bin` / `code-oss`) |
| **Font Terminal** | JetBrainsMono Nerd Font (`ttf-jetbrains-mono-nerd`) |
| **Font Editor** | Fira Code (`ttf-fira-code`) dengan ligatures |
| **Clipboard CLI** | `wl-clipboard` (`wl-copy`, `wl-paste`) |

---

## 📂 Struktur Repositori

```text
~/Lab/dotfile_v2/ (atau ~/dotfiles/)
├── git/
│   └── .gitconfig          # Konfigurasi Git: identitas, branch main, autocorrect
├── kitty/
│   └── kitty.conf          # Konfigurasi Kitty (tema Gundam 00 Glassmorphism)
├── package-mapping.md      # Tabel pemetaan dependencies Debian (APT) ke Arch (Pacman/AUR)
├── README.md               # Dokumentasi lengkap repositori (khusus Manjaro GNOME)
├── setup.sh                # Script instalasi & symlink otomatis (Bash)
├── shell/
│   ├── .bashrc             # Baseline konfigurasi Bash + NVM hook
│   └── .zshrc              # Zshrc aktif: Pacman/Yay aliases, GNOME session, Dev stack
├── starship/
│   └── starship.toml       # Tema Starship Gundam Trans-AM (ikon Manjaro  )
└── vscode/
    ├── extensions.list     # Daftar 43 ekstensi aktif VS Code
    ├── keybindings.json    # Shortcut produktivitas VS Code
    ├── settings.json       # Settings UI, linter, formatter, & layout editor
    └── snippets/           # User code snippets (.gitkeep)
```

---

## 🚀 Panduan Instalasi Cepat

### 1. Klon Repositori ke Direktori Lokal
Jika repositori belum berada di mesin lokal:
```bash
git clone https://github.com/<username>/dotfile_v2.git ~/Lab/dotfile_v2
cd ~/Lab/dotfile_v2
```

### 2. Jalankan Uji Coba Simulasi (Dry-Run)
Pastikan semua target path dan dependensi terdeteksi tanpa mengubah file sistem:
```bash
./setup.sh --dry-run
```

### 3. Eksekusi Pemasangan Otomatis
Jalankan script untuk memasang seluruh paket inti, membuat symlink, dan memulihkan ekstensi VS Code:
```bash
./setup.sh
```

---

## ⚙️ Opsi & Flag Script (`setup.sh`)

Script [`setup.sh`](./setup.sh) memiliki opsi modular:

```bash
# Lewati instalasi paket Pacman (hanya pasang symlink & ekstensi)
./setup.sh --skip-packages

# Lewati instalasi ekstensi VS Code
./setup.sh --skip-extensions

# Hanya perbarui symlink konfigurasi (sangat cepat)
./setup.sh --skip-packages --skip-extensions

# Tampilkan panduan flag
./setup.sh --help
```

---

## 🛠️ Langkah Pasca Instalasi (Post-Install)

Setelah script `setup.sh` selesai dijalankan, lakukan beberapa langkah penyempurnaan di Manjaro GNOME:

### 1. Set ZSH sebagai Default Shell
```bash
chsh -s $(which zsh)
```
*(Logout lalu login kembali agar default shell diterapkan).*

### 2. Pasang Oh My Zsh & Custom Plugins
Jika Oh My Zsh belum terpasang di sistem baru:
```bash
# Pasang Oh My Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Unduh plugin eksternal yang diaktifkan di .zshrc
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-completions
git clone https://github.com/Aloxaf/fzf-tab ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/fzf-tab
```

### 3. Pasang AUR Helper (Yay)
Manjaro sudah menyediakan `pamac`, namun `yay` sangat direkomendasikan untuk instalasi package dari AUR:
```bash
sudo pacman -S --needed base-devel git
git clone https://aur.archlinux.org/yay.git /tmp/yay
cd /tmp/yay && makepkg -si
```

### 4. Setup Node.js (NVM) & Modern Package Managers
```bash
# Pasang NVM
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash

# Reload zsh
source ~/.zshrc

# Pasang versi Node.js LTS terbaru
nvm install --lts
nvm use --lts

# Pasang Yarn & Pnpm
sudo pacman -S yarn pnpm
```

### 5. Setup Database & Backend Services
Aktifkan service database lokal saat dibutuhkan:
```bash
# PostgreSQL
sudo -u postgres initdb -D /var/lib/postgres/data
sudo systemctl enable --now postgresql

# MariaDB / MySQL
sudo mariadb-install-db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
sudo systemctl enable --now mariadb

# Redis
sudo systemctl enable --now redis
```

---

## ⚡ Konfigurasi ZSH & Daftar Alias

File [`.zshrc`](./shell/.zshrc) telah disesuaikan sepenuhnya untuk Manjaro GNOME. Berikut ringkasan alias yang tersedia:

### 📦 Manajemen Paket (Pacman, Pamac, Yay)
| Alias | Perintah Asli | Deskripsi |
|---|---|---|
| `update` | `sudo pacman -Syu` | Sinkronisasi & update seluruh paket sistem |
| `upgrade` | `sudo pacman -Syu` | Alias untuk update sistem |
| `install <pkg>` | `sudo pacman -S <pkg>` | Pasang paket dari repositori resmi |
| `remove <pkg>` | `sudo pacman -Rns <pkg>` | Hapus paket beserta dependensi tak terpakai |
| `search <query>` | `pacman -Ss <query>` | Cari paket di repositori |
| `autoremove` | `pacclean` | Hapus semua orphaned packages secara aman |
| `pupdate` | `pamac update` | Update via Manjaro Pamac CLI |
| `pinstall <pkg>` | `pamac install <pkg>` | Pasang paket via Pamac |
| `yupdate` | `yay -Syu` | Update paket resmi dan AUR via Yay |
| `yinstall <pkg>` | `yay -S <pkg>` | Pasang paket dari AUR |
| `ysearch <query>` | `yay -Ss <query>` | Cari paket di AUR & repositori resmi |

### 🪟 GNOME Session & Desktop Controls
| Alias | Perintah Asli | Deskripsi |
|---|---|---|
| `logout` | `gnome-session-quit --logout --no-prompt` | Keluar dari sesi GNOME |
| `lock` | `loginctl lock-session` | Kunci layar desktop |
| `ribut` | `sudo reboot` | Restart komputer |
| `matikan` / `shutdown` | `sudo poweroff` | Matikan komputer |
| `gnome-ver` | `gnome-shell --version` | Cek versi GNOME Shell |
| `copy` | `wl-copy` | Salin teks ke clipboard Wayland |
| `paste` | `wl-paste` | Tempel teks dari clipboard Wayland |
| `open <file/url>` | `xdg-open <file/url>` | Buka file/URL dengan aplikasi default |

### 🔍 Navigasi & File CLI
| Alias | Perintah Asli | Deskripsi |
|---|---|---|
| `ls` | `eza --icons` | Daftar file modern dengan icon |
| `ll` | `eza --icons -lah` | Tampilan detail list lengkap |
| `la` | `eza --icons -a` | Tampilan file tersembunyi (hidden) |
| `tree` | `eza --icons --tree` | Tampilan hierarki pohon direktori |
| `cd <dir>` | `z <dir>` | Smart jumping ke direktori via Zoxide |
| `cat <file>` | `bat <file>` | Syntax highlighting viewer (Arch native `bat`) |
| `find <query>` | `fd <query>` | Pencarian file ultra cepat via `fd` |
| `grep <query>` | `rg <query>` | Pencarian teks cepat via Ripgrep |
| `c` / `.c` | `code` / `code .` | Buka Visual Studio Code |

### ⚛️ Developer Stacks (React/TS, Rails, Laravel)
| Alias | Perintah Asli | Ekosistem |
|---|---|---|
| `ys` / `yd` / `yb` | `yarn start` / `yarn dev` / `yarn build` | Yarn |
| `pd` / `pb` | `pnpm dev` / `pnpm build` | PNPM |
| `rs` / `rc` / `rd` | `bin/rails server` / `console` / `bin/dev` | Ruby on Rails |
| `dbm` / `dbr` | `bin/rails db:migrate` / `rollback` | Rails DB |
| `pa` / `pas` / `pam` | `php artisan` / `serve` / `migrate` | Laravel |
| `fresh` | `php artisan migrate:fresh --seed` | Laravel Refresh |
| `tinker` | `php artisan tinker` | Laravel REPL |
| `forg` | `cd project/forge/forge` | Quick Project Jump |
| `dev` | `cd project` | Quick Project Jump |

---

## 🪟 Penyesuaian Khusus Manjaro GNOME Desktop

### 1. Ekstensi GNOME yang Direkomendasikan
Untuk menyempurnakan tampilan estetika dan produktivitas:
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
   - Menampilkan ikon tray aplikasi di top bar (seperti Discord, Spotify, VS Code):
     ```bash
     sudo pacman -S gnome-shell-extension-appindicator
     ```

*Aktifkan ekstensi di atas melalui aplikasi **Extension Manager** (`pamac install extension-manager`).*

### 2. Navigasi Gestures Bawaan GNOME Wayland
GNOME di Wayland memiliki navigasi touchpad 1:1 multi-finger:
- **Swipe 3 jari ke atas**: Buka Overview & Application Grid.
- **Swipe 3 jari ke kiri/kanan**: Berpindah antar Workspace secara instan.
- **Pinch 2 jari**: Zoom in/out pada aplikasi yang didukung.

---

## 🔄 Pemetaan Paket (Mint / APT → Manjaro / Pacman)

| Utility | Linux Mint (APT) | Manjaro (Pacman / AUR) | Catatan Binary |
|---|---|---|---|
| Modern `ls` | `apt install eza` | `sudo pacman -S eza` | Binary: `eza` |
| Fast `cat` | `apt install bat` (`batcat`) | `sudo pacman -S bat` | **Di Manjaro binary adalah `bat` (bukan `batcat`)** |
| Fast `find` | `apt install fd-find` (`fdfind`) | `sudo pacman -S fd` | **Di Manjaro binary adalah `fd` (bukan `fdfind`)** |
| Code Search | `apt install ripgrep` | `sudo pacman -S ripgrep` | Binary: `rg` |
| Fuzzy Finder | `apt install fzf` | `sudo pacman -S fzf` | Scripts di `/usr/share/fzf/` |
| Prompt | Cargo / Homebrew | `sudo pacman -S starship` | Konfigurasi di `~/.config/starship.toml` |
| Terminal | `apt install kitty` | `sudo pacman -S kitty` | GPU accelerated, Wayland native |
| VS Code | DEB package | `yay -S visual-studio-code-bin` | Official binary Microsoft |
| Clipboard | `xclip` | `sudo pacman -S wl-clipboard` | `wl-copy` & `wl-paste` native Wayland |

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
sudo pacman -S --needed ttf-jetbrains-mono-nerd ttf-fira-code
fc-cache -fv
```

### 3. FZF Keybindings (Ctrl+R / Ctrl+T) Belum Aktif
Pastikan paket `fzf` sudah terpasang via pacman:
```bash
sudo pacman -S fzf
source ~/.zshrc
```
File `.zshrc` akan otomatis memuat `/usr/share/fzf/key-bindings.zsh` dan `/usr/share/fzf/completion.zsh`.

---

## 👤 Pengembang

- **Author**: `parikesitad-pm`
- **Role**: Project Analyst, QA Tester & Full-Stack Developer
- **Target OS**: Manjaro Linux (GNOME Edition)
- **Theme Concept**: Gundam 00 // Celestial Being Trans-AM Glassmorphism

---
*Happy Hacking on Manjaro GNOME!* 🚀
