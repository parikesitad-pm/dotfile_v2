<#
.SYNOPSIS
    Automated Antigravity CLI (agy) Setup Script for Windows.
    Crafted for parikesitad-pm.

.DESCRIPTION
    Installs:
    1. 2-Line Custom StatusLine (Live Tokens, Quota 5h countdown, Git branch, Owl 🦉, Branding)
    2. Desktop Notification Hook on task completion (Toast / Balloon + Chime sound)
    3. Auto-configures ~/.gemini/antigravity-cli/settings.json and ~/.gemini/config/hooks.json

.USAGE
    powershell -ExecutionPolicy Bypass -File .\install-windows.ps1
#>

$ErrorActionPreference = "Stop"

Write-Host "🦉 [Antigravity Setup] Memulai instalasi racikan agy untuk Windows..." -ForegroundColor Cyan

# 1. Tentukan path tujuan
$UserProfile = [System.Environment]::GetFolderPath('UserProfile')
$TargetAgyDir = Join-Path $UserProfile ".config\agy"
$GeminiCliDir = Join-Path $UserProfile ".gemini\antigravity-cli"
$GeminiConfigDir = Join-Path $UserProfile ".gemini\config"

$SettingsFile = Join-Path $GeminiCliDir "settings.json"
$HooksFile = Join-Path $GeminiConfigDir "hooks.json"

# Buat folder jika belum ada
New-Item -ItemType Directory -Force -Path $TargetAgyDir | Out-Null
New-Item -ItemType Directory -Force -Path $GeminiCliDir | Out-Null
New-Item -ItemType Directory -Force -Path $GeminiConfigDir | Out-Null

$CurrentDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# 2. Copy statusline.py dan notify.py
$StatuslineSrc = Join-Path $CurrentDir "statusline.py"
$NotifySrc = Join-Path $CurrentDir "notify.py"

$StatuslineDest = Join-Path $TargetAgyDir "statusline.py"
$NotifyDest = Join-Path $TargetAgyDir "notify.py"

Copy-Item -Path $StatuslineSrc -Destination $StatuslineDest -Force
Copy-Item -Path $NotifySrc -Destination $NotifyDest -Force

Write-Host "✅ statusline.py & notify.py berhasil disalin ke $TargetAgyDir" -ForegroundColor Green

# 3. Update settings.json
$StatuslineEscaped = $StatuslineDest.Replace("\", "\\")

$Settings = @{}
if (Test-Path $SettingsFile) {
    try {
        $RawContent = Get-Content $SettingsFile -Raw -Encoding UTF8
        if ($RawContent.Trim()) {
            $Settings = $RawContent | ConvertFrom-Json -AsHashtable
        }
    } catch {
        Write-Warning "Gagal parse settings.json lama, membuat backup baru..."
        Copy-Item $SettingsFile "$SettingsFile.bak" -Force
        $Settings = @{}
    }
}

$Settings["allowNonWorkspaceAccess"] = $true
$Settings["artifactReviewPolicy"] = "always-proceed"

if (-not $Settings.ContainsKey("statusLine")) {
    $Settings["statusLine"] = @{}
}
$Settings["statusLine"]["type"] = ""
$Settings["statusLine"]["command"] = "python `"$StatuslineDest`""

# Tambahkan permission bypass jika ada
if (-not $Settings.ContainsKey("permissions")) {
    $Settings["permissions"] = @{ "allow" = @() }
}
if (-not $Settings["permissions"].ContainsKey("allow")) {
    $Settings["permissions"]["allow"] = @()
}

$PermCmd = "command(python `"$StatuslineDest`")"
if ($Settings["permissions"]["allow"] -notcontains $PermCmd) {
    $Settings["permissions"]["allow"] += $PermCmd
}

$SettingsJson = $Settings | ConvertTo-Json -Depth 10
[System.IO.File]::WriteAllText($SettingsFile, $SettingsJson, [System.Text.Encoding]::UTF8)

Write-Host "✅ settings.json berhasil diupdate (StatusLine terhubung)." -ForegroundColor Green

# 4. Update hooks.json (Desktop Notification saat agent stop)
$Hooks = @{}
if (Test-Path $HooksFile) {
    try {
        $RawHooks = Get-Content $HooksFile -Raw -Encoding UTF8
        if ($RawHooks.Trim()) {
            $Hooks = $RawHooks | ConvertFrom-Json -AsHashtable
        }
    } catch {
        $Hooks = @{}
    }
}

$Hooks["desktop-notification"] = @{
    "enabled" = $true
    "Stop" = @(
        @{
            "type" = "command"
            "command" = "python `"$NotifyDest`""
            "timeout" = 5
        }
    )
}

$HooksJson = $Hooks | ConvertTo-Json -Depth 10
[System.IO.File]::WriteAllText($HooksFile, $HooksJson, [System.Text.Encoding]::UTF8)

Write-Host "✅ hooks.json berhasil diupdate (Desktop Notification terpasang)." -ForegroundColor Green

Write-Host "`n🎉 SELESAI! Setup agy untuk Windows sukses 100%!" -ForegroundColor Cyan
Write-Host "Silakan buka terminal baru dan jalankan `agy`." -ForegroundColor Yellow
