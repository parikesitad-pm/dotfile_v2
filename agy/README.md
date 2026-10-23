# 🦉 Antigravity CLI (`agy`) Custom Setup

> Paket kustomisasi lengkap Antigravity CLI untuk Linux & Windows: 2-Line StatusLine, Live Quota Monitor, Git Branch Tracker, Owl Mascot, dan Desktop Notification Hook saat tugas selesai.

---

## 📦 Isi Paket

| File | Fungsi |
|---|---|
| [`statusline.py`](statusline.py) | Script statusline 2-baris (cross-platform Linux & Windows). |
| [`notify.py`](notify.py) | Script desktop notification & sound chime saat agent selesai. |
| [`install-windows.ps1`](install-windows.ps1) | 1-click installer otomatis untuk Windows PowerShell. |
| [`install-linux.sh`](install-linux.sh) | 1-click installer otomatis untuk Linux. |

---

## 🎨 Tampilan StatusLine

```text
🦉 ⚡ 232.3k (11.1%) │ 💎 75% (3j 22m) │  main*
a modula project crafted with <3 by parikesitad-pm support by Gemini 4 Argon • high
```

* **Baris 1**:
  * 🦉 **Mascot Owl**
  * ⚡ **Token Stats** (total token + persentase context window)
  * 💎 **Live Quota** (sisa kuota Gemini 5 jam + hitung mundur waktu reset)
  *  **Git Branch** (nama branch aktif + tanda `*` jika dirty/ada uncommitted changes)
* **Baris 2**:
  * Branding: `a modula project crafted with <3 by parikesitad-pm support by Gemini 4 Argon • high` (otomatis responsif mengecil jika terminal dipersempit)

---

## 🔔 Desktop Notification (Hook)

Setiap kali agent selesai mengeksekusi tugas panjang atau `/goal`:
* **Linux**: Muncul popup notifikasi `notify-send` + bunyi chime freedesktop stereo.
* **Windows**: Muncul Windows Toast / Balloon Tip + bunyi Asterisk chime Windows.

---

## 🚀 Cara Pasang di Windows (1-Click)

1. Copy folder `agy` ini ke komputer Windows kamu (atau clone repo dotfiles).
2. Buka **PowerShell** di dalam folder `agy` tersebut.
3. Jalankan command:
   ```powershell
   powershell -ExecutionPolicy Bypass -File .\install-windows.ps1
   ```
4. Buka terminal baru dan jalankan `agy`!

> [!TIP]
> Script installer Windows otomatis menyalin script ke `%USERPROFILE%\.config\agy` serta memperbarui konfigurasi di:
> * `%USERPROFILE%\.gemini\antigravity-cli\settings.json` (StatusLine)
> * `%USERPROFILE%\.gemini\config\hooks.json` (Notification Hook)

---

## 🐧 Cara Pasang di Linux

Cukup jalankan:
```bash
./install-linux.sh
```
