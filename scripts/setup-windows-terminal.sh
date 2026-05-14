#!/usr/bin/env bash
# Windows-side setup for the Nexo WSL profile in Windows Terminal:
#   - installs CaskaydiaCove Nerd Font Mono (per-user, no admin needed)
#   - adds the "Nexo Half Dark" color scheme
#   - sets the Nexo profile to use the scheme + font
#
# Run from inside the Nexo WSL distro:
#   bash ~/.dotfiles/scripts/setup-windows-terminal.sh
#
# Idempotent: safe to re-run. Existing files are backed up.

set -euo pipefail

readonly STEP="windows-setup"

# Sanity-check: we have to be inside WSL on a Windows host
if ! grep -qi microsoft /proc/version 2>/dev/null; then
    echo "[$STEP] not running under WSL — nothing to do here." >&2
    exit 0
fi

# Locate the Windows user home via cmd.exe (avoids hard-coding the username)
WIN_USER="$(/mnt/c/Windows/System32/cmd.exe /c 'echo %USERNAME%' 2>/dev/null | tr -d '\r')"
WIN_HOME="/mnt/c/Users/$WIN_USER"
WT_SETTINGS="$WIN_HOME/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json"

if [ ! -f "$WT_SETTINGS" ]; then
    echo "[$STEP] Windows Terminal settings not found at:" >&2
    echo "    $WT_SETTINGS" >&2
    echo "[$STEP] (install Windows Terminal and open it once, then re-run.)" >&2
    exit 1
fi

# ────────────────────────────────────────────────────────────────────
# 1. Install CaskaydiaCove Nerd Font Mono (user-level)
# ────────────────────────────────────────────────────────────────────
FONT_DIR="$WIN_HOME/AppData/Local/Microsoft/Windows/Fonts"
FONT_FILES=(
    "CaskaydiaCoveNerdFontMono-Regular.ttf"
    "CaskaydiaCoveNerdFontMono-Bold.ttf"
    "CaskaydiaCoveNerdFontMono-Italic.ttf"
    "CaskaydiaCoveNerdFontMono-BoldItalic.ttf"
)

if [ -f "$FONT_DIR/${FONT_FILES[0]}" ]; then
    echo "[$STEP] CaskaydiaCove NFM already installed."
else
    echo "[$STEP] downloading CaskaydiaCove Nerd Font..."
    TMP="$(mktemp -d)"
    trap 'rm -rf "$TMP"' EXIT
    curl -fsSL -o "$TMP/CascadiaCode.zip" \
        "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/CascadiaCode.zip"
    unzip -q "$TMP/CascadiaCode.zip" -d "$TMP/extracted"

    mkdir -p "$FONT_DIR"
    for f in "${FONT_FILES[@]}"; do
        cp "$TMP/extracted/$f" "$FONT_DIR/"
    done

    echo "[$STEP] registering fonts in HKCU..."
    /mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe \
        -NoProfile -Command @'
$ErrorActionPreference = "Stop"
$fontDir = "$env:LOCALAPPDATA\Microsoft\Windows\Fonts"
$regPath = "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Fonts"

Add-Type @"
using System.Runtime.InteropServices;
public class FontApi {
    [DllImport("gdi32.dll")] public static extern int AddFontResource(string p);
    [DllImport("user32.dll")] public static extern int SendMessage(int h, int m, int w, int l);
}
"@

$fonts = @{
    "CaskaydiaCoveNerdFontMono-Regular.ttf"    = "CaskaydiaCove NFM Regular (TrueType)"
    "CaskaydiaCoveNerdFontMono-Bold.ttf"       = "CaskaydiaCove NFM Bold (TrueType)"
    "CaskaydiaCoveNerdFontMono-Italic.ttf"     = "CaskaydiaCove NFM Italic (TrueType)"
    "CaskaydiaCoveNerdFontMono-BoldItalic.ttf" = "CaskaydiaCove NFM Bold Italic (TrueType)"
}

foreach ($file in $fonts.Keys) {
    $path = Join-Path $fontDir $file
    if (Test-Path $path) {
        New-ItemProperty -Path $regPath -Name $fonts[$file] -Value $path -PropertyType String -Force | Out-Null
        [FontApi]::AddFontResource($path) | Out-Null
    }
}
[FontApi]::SendMessage(0xFFFF, 0x001D, 0, 0) | Out-Null
'@
    echo "[$STEP] font installed."
fi

# ────────────────────────────────────────────────────────────────────
# 2. Patch Windows Terminal settings.json
#    - adds the "Nexo Half Dark" scheme if absent
#    - sets the Nexo profile's colorScheme + font
# ────────────────────────────────────────────────────────────────────
echo "[$STEP] patching $WT_SETTINGS..."

BACKUP="$WT_SETTINGS.bak-$(date +%Y%m%d-%H%M%S)"
cp "$WT_SETTINGS" "$BACKUP"
echo "[$STEP] backup: $BACKUP"

read -r -d '' NEXO_SCHEME <<'EOF' || true
{
    "name": "Nexo Half Dark",
    "background": "#000000",
    "foreground": "#DCDFE4",
    "cursorColor": "#FFFFFF",
    "selectionBackground": "#FFFFFF",
    "black": "#000000",
    "red": "#E53E3E",
    "green": "#42BF35",
    "yellow": "#DCAE26",
    "blue": "#61AFEF",
    "purple": "#C678DD",
    "cyan": "#43A4D0",
    "white": "#DCDFE4",
    "brightBlack": "#5A6374",
    "brightRed": "#E53E3E",
    "brightGreen": "#42BF35",
    "brightYellow": "#DCAE26",
    "brightBlue": "#61AFEF",
    "brightPurple": "#C678DD",
    "brightCyan": "#43A4D0",
    "brightWhite": "#DCDFE4"
}
EOF

# jq: add scheme if missing, then set scheme+font on any profile named "Nexo".
jq --argjson scheme "$NEXO_SCHEME" '
    (.schemes //= [])
  | .schemes |= (if any(.name == "Nexo Half Dark") then . else . + [$scheme] end)
  | .profiles.list |= map(
        if .name == "Nexo" then
            . + { "colorScheme": "Nexo Half Dark",
                  "font": { "face": "CaskaydiaCove NFM" } }
        else . end)
' "$BACKUP" > "$WT_SETTINGS"

echo "[$STEP] done."
echo "[$STEP] restart Windows Terminal to apply (close all windows, reopen)."
