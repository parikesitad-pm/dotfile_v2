#!/usr/bin/env bash
set -e

echo "🦉 [Antigravity Setup] Menyiapkan konfigurasi agy untuk Linux..."

AGY_CONFIG_DIR="$HOME/.config/agy"
GEMINI_CLI_DIR="$HOME/.gemini/antigravity-cli"
GEMINI_CONFIG_DIR="$HOME/.gemini/config"

mkdir -p "$AGY_CONFIG_DIR" "$GEMINI_CLI_DIR" "$GEMINI_CONFIG_DIR"

chmod +x "$AGY_CONFIG_DIR/statusline.py" "$AGY_CONFIG_DIR/notify.py" 2>/dev/null || true

python3 - << 'EOF'
import json, os

home = os.path.expanduser("~")
settings_file = os.path.join(home, ".gemini/antigravity-cli/settings.json")
hooks_file = os.path.join(home, ".gemini/config/hooks.json")
statusline_script = os.path.join(home, ".config/agy/statusline.py")
notify_script = os.path.join(home, ".config/agy/notify.py")

# Settings.json
settings = {}
if os.path.exists(settings_file):
    try:
        with open(settings_file, "r") as f:
            settings = json.load(f)
    except:
        settings = {}

settings["allowNonWorkspaceAccess"] = True
settings["artifactReviewPolicy"] = "always-proceed"
if "statusLine" not in settings or not isinstance(settings["statusLine"], dict):
    settings["statusLine"] = {}
settings["statusLine"]["type"] = ""
settings["statusLine"]["command"] = statusline_script

perms = settings.setdefault("permissions", {}).setdefault("allow", [])
for cmd in [f"command({statusline_script})", f"command({notify_script})", f"command(python3 {notify_script})"]:
    if cmd not in perms:
        perms.append(cmd)

with open(settings_file, "w") as f:
    json.dump(settings, f, indent=2)

# Hooks.json
hooks = {}
if os.path.exists(hooks_file):
    try:
        with open(hooks_file, "r") as f:
            hooks = json.load(f)
    except:
        hooks = {}

hooks["desktop-notification"] = {
    "enabled": True,
    "Stop": [
        {
            "type": "command",
            "command": notify_script,
            "timeout": 5
        }
    ]
}

with open(hooks_file, "w") as f:
    json.dump(hooks, f, indent=2)

print("✅ settings.json & hooks.json tersinkronisasi!")
EOF

echo "🎉 Setup Linux selesai!"
