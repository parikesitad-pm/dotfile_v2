#!/usr/bin/env python3
"""
Cross-Platform Notification Hook for Antigravity CLI (agy).
Runs on Stop event:
- Linux: notify-send + freedesktop sound chime
- Windows: PowerShell Toast / Balloon tip + Asterisk sound
"""

import sys
import json
import os
import subprocess

def play_sound_linux():
    # Try canberra-gtk-play first
    try:
        subprocess.Popen(
            ["canberra-gtk-play", "-i", "complete"],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            start_new_session=True
        )
        return
    except Exception:
        pass

    # Fallback to paplay with standard complete sound
    sound_path = "/usr/share/sounds/freedesktop/stereo/complete.oga"
    if os.path.exists(sound_path):
        try:
            subprocess.Popen(
                ["paplay", sound_path],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
                start_new_session=True
            )
        except Exception:
            pass

def notify_linux(title: str, message: str):
    try:
        subprocess.run(
            ["notify-send", "-a", "Antigravity", "-i", "terminal", title, message],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            timeout=2
        )
    except Exception:
        pass
    play_sound_linux()

def notify_windows(title: str, message: str):
    ps_script = f"""
[System.Media.SystemSounds]::Asterisk.Play()
Add-Type -AssemblyName System.Windows.Forms
$balloon = New-Object System.Windows.Forms.NotifyIcon
$balloon.Icon = [System.Drawing.SystemIcons]::Information
$balloon.BalloonTipTitle = '{title}'
$balloon.BalloonTipText = '{message}'
$balloon.Visible = $true
$balloon.ShowBalloonTip(4000)
Start-Sleep -Seconds 1
$balloon.Dispose()
"""
    try:
        subprocess.Popen(
            ["powershell", "-NoProfile", "-WindowStyle", "Hidden", "-Command", ps_script],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL
        )
    except Exception:
        pass

def main():
    try:
        raw = sys.stdin.read()
        payload = json.loads(raw) if raw.strip() else {}
    except Exception:
        payload = {}

    reason = payload.get("terminationReason", "model_stop")
    title = "Antigravity CLI (agy)"
    message = "Tugas selesai! Siap untuk instruksi berikutnya 🦉"

    # Only notify on normal completion or error stop
    if reason in ("model_stop", "error", ""):
        if sys.platform == "win32":
            notify_windows(title, message)
        else:
            notify_linux(title, message)

    # Hook spec requires JSON output on stdout
    sys.stdout.write("{}\n")
    sys.stdout.flush()

if __name__ == "__main__":
    main()
