# 🛸 Gundam 00 // Celestial Being Dotfiles

> Modular, aesthetic, and automated dotfiles optimized for Full-Stack Developers (React/TS, Ruby on Rails, Laravel/PHP). Pre-configured and tested for migration from Linux Mint to **Manjaro GNOME (Arch-based)**.

---

## 📑 Daftar Isi

- [Fitur Utama](#-fitur-utama)
- [Spesifikasi Lingkungan](#-spesifikasi-lingkungan)
- [Struktur Repositori](#-struktur-repositori)
- [Panduan Instalasi Cepat](#-panduan-instalasi-cepat)
- [Opsi & Flag Script (`setup.sh`)](#-opsi--flag-script-setupsh)
- [Langkah Pasca Instalasi (Post-Install)](#-langkah-pasca-instalasi-post-install)
- [Penyesuaian Khusus GNOME](#-penyesuaian-khusus-gnome-dari-xfce)
- [Pemetaan Paket (Mint / APT → Manjaro / Pacman)](#-pemetaan-paket-mint--apt--manjaro--pacman)
- [Manajemen Backup & Rollback](#-manajemen-backup--rollback)
- [Kontributor & Lisensi](#-kontributor--lisensi)

---

## ✨ Fitur Utama

- 🎨 **Gundam 00 "Celestial Being" Aesthetic**:
  - **Kitty Terminal**: Glassmorphism transparan (opacity 0.85), custom GN-drive/Trans-AM palette, slanted powerline tabs.
  - **Starship Prompt**: Skema warna Trans-AM merah/crimson dengan modul cerdas (status Git, deteksi runtime Node/Ruby/PHP/Go/Rust, dan format direktori bersih).
  - **VS Code**: Tema *Tokyo Night Dark*, font *Fira Code* dengan ligatures aktif, dan pengaturan formatting terintegrasi (Prettier, ESLint, Intelephense, Blade, Ruby LSP).
- 🛡️ **Safe & Non-Destructive Deployment**:
  - Script otomatis membuat cadangan bertanggal (`.bak.<timestamp>`) sebelum menimpa konfigurasi yang sudah ada.
  - Menggunakan symlink idempotent (`ln -sfn`), sehingga aman dijalankan berulang kali.
- 📦 **Automated Extension Restore**:
  - Otomatis mengembalikan 40+ ekstensi VS Code penting hanya dengan satu perintah.
- ⚡ **Arch/Manjaro Native**:
  - Disesuaikan sepenuhnya dengan binary standar Arch (`bat`, `fd`, `eza`, `pacman`, `yay`).

---

## 🖥️ Spesifikasi Lingkungan

| Komponen | Konfigurasi Default |
|---|---|
| **Distro Target** | Manjaro Linux (GNOME Edition) / Arch Linux |
| **Distro Asal** | Linux Mint 22 (XFCE Edition) |
| **Shell** | Zsh + Oh My Zsh (Fallback: Bash) |
| **Prompt** | Starship Cross-Shell Prompt |
| **Terminal Emulator** | Kitty (GPU Accelerated) |
| **Editor Utama** | Visual Studio Code (`code` / `code-oss`) |
| **Font Terminal** | JetBrainsMono Nerd Font Mono |
| **Font Editor** | Fira Code (Ligatures Enabled) |

---

## 📂 Struktur Repositori

```text
~/dotfiles/
├── git/
│   └── .gitconfig          # Identitas Git, default branch main, autocrlf, GH helper
├── kitty/
│   └── kitty.conf          # Konfigurasi Kitty (tema Gundam 00 Glassmorphism)
├── package-mapping.md      # Tabel pemetaan dependencies Debian (APT) ke Arch (Pacman/AUR)
├── README.md               # Dokumentasi utama repositori
├── setup.sh                # Master deployment script (Bash, executable)
├── shell/
│   ├── .bashrc             # Baseline konfigurasi Bash + NVM hook
│   └── .zshrc              # Zshrc aktif: OMZ, plugin fzf-tab, manpage color, alias dev
├── starship/
│   └── starship.toml       # Tema Starship Gundam Trans-AM
└── vscode/
    ├── extensions.list     # Daftar 43 ekstensi aktif VS Code
    ├── keybindings.json    # Shortcut produktivitas VS Code kustom
    ├── settings.json       # Settings UI, linter, formatter, & layout editor
    └── snippets/           # User code snippets
```

---

## 🚀 Panduan Instalasi Cepat

### 1. Klon Repositori ke Home Directory
Di sistem target Manjaro GNOME, buka terminal dan jalankan:
```bash
git clone https://github.com/<username>/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

### 2. Jalankan Simulasi (Dry-Run)
Selalu disarankan menguji jalannya script tanpa mengubah sistem terlebih dahulu:
```bash
./setup.sh --dry-run
```

### 3. Eksekusi Pemasangan Otomatis
Jika hasil simulasi sudah sesuai, jalankan deployment penuh:
```bash
./setup.sh
```

---

## ⚙️ Opsi & Flag Script (`setup.sh`)

Script [`setup.sh`](./setup.sh) mendukung beberapa flag fleksibel:

```bash
# Menjalankan instalasi tanpa mengunduh ulang paket pacman
./setup.sh --skip-packages

# Menjalankan symlink tanpa menginstal ulang extension VS Code
./setup.sh --skip-extensions

# Menggabungkan flag: Hanya symlink file konfigurasi saja
./setup.sh --skip-packages --skip-extensions

# Menampilkan bantuan
./setup.sh --help
```

---

## 🛠️ Langkah Pasca Instalasi (Post-Install)

Setelah script `setup.sh` selesai dijalankan, lakukan beberapa langkah penyempurnaan berikut:

### 1. Ubah Default Shell ke ZSH (jika belum aktif)
```bash
chsh -s $(which zsh)
```
*(Logout lalu login kembali agar perubahan shell diterapkan).*

### 2. Pasang Oh My Zsh & Plugin Eksternal
Jika Oh My Zsh belum terpasang di sistem baru:
```bash
# Pasang Oh My Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Pasang custom plugin yang digunakan pada .zshrc
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-completions
git clone https://github.com/Aloxaf/fzf-tab ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/fzf-tab
```

### 3. Pasang Font Pendukung
Agar glyph dan icon di Kitty, Starship, dan VS Code tampil sempurna:
```bash
sudo pacman -S --needed ttf-jetbrains-mono-nerd ttf-fira-code
```

### 4. Pasang Node Version Manager (NVM) & Runtimes
```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
source ~/.zshrc
nvm install --lts
```

---

## 🪟 Penyesuaian Khusus GNOME (dari XFCE)

Karena sistem target menggunakan **GNOME Desktop**, beberapa utility lama dari XFCE tidak lagi digunakan dan telah digantikan:

1. **Pengganti Plank (Dock)**:
   - Gunakan ekstensi GNOME **Dash to Dock** untuk mendapatkan dock bergaya macOS:
     ```bash
     sudo pacman -S gnome-shell-extension-dash-to-dock
     ```
   - Aktifkan via aplikasi `Extensions` atau `Extension Manager`.

2. **Touchpad Gestures (Touchegg)**:
   - GNOME Wayland sudah memiliki navigasi swipe 1:1 bawaan (3-jari untuk overview, 4-jari untuk switch workspace), sehingga service `touchegg` tidak lagi dibutuhkan.

3. **Window Transparency & Blur (Opsional)**:
   - Pasang ekstensi **Blur my Shell** untuk mendapatkan estetika glassmorphism maksimal yang selaras dengan Kitty terminal.

---

## 🔄 Pemetaan Paket (Mint / APT → Manjaro / Pacman)

| Kebutuhan | Perintah di Mint (APT) | Perintah di Manjaro (Pacman / AUR) |
|---|---|---|
| Modern `ls` | `apt install eza` | `sudo pacman -S eza` |
| Fast `cat` | `apt install bat` (`batcat`) | `sudo pacman -S bat` |
| Fast `find` | `apt install fd-find` (`fdfind`) | `sudo pacman -S fd` |
| Grep search | `apt install ripgrep` | `sudo pacman -S ripgrep` |
| Terminal | `apt install kitty` | `sudo pacman -S kitty` |
| Prompt | `cargo install starship` | `sudo pacman -S starship` |
| VS Code Official | `apt install code` | `yay -S visual-studio-code-bin` |
| Database Client | `apt install postgresql mariadb-server` | `sudo pacman -S postgresql mariadb` |

> *Detail pemetaan lengkap seluruh dependencies dan service developer dapat dibaca di [package-mapping.md](./package-mapping.md).*

---

## ⏪ Manajemen Backup & Rollback

Setiap kali `setup.sh` mendeteksi file konfigurasi lama di sistem target:
1. File lama **tidak langsung ditimpa**, melainkan dipindahkan ke file cadangan dengan format:
   ```text
   <path-file-asli>.bak.YYYYMMDD_HHMMSS
   ```
   *Contoh:* `~/.zshrc.bak.20260911_043043`
2. Untuk mengembalikan konfigurasi lama jika terjadi kendala:
   ```bash
   # Hapus symlink dotfiles
   rm ~/.zshrc
   # Pulihkan file backup
   mv ~/.zshrc.bak.20260911_043043 ~/.zshrc
   ```

---

## 👤 Pengembang

- **Author**: `parikesitad-pm`
- **Role**: Project Analyst, QA Tester & Full-Stack Developer
- **Email**: `parikesit.ad@gmail.com`

---
*Happy Hacking with Manjaro GNOME & Celestial Being Dotfiles!* 🚀
