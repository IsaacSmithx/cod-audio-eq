<#
.SYNOPSIS
    COD Audio EQ - Profile V3 (Competitive - Refined)

.DESCRIPTION
    Writes the V3 Equalizer APO filter set to the config file that APO
    watches for the Elgato 4K X capture endpoint, and ONLY that endpoint.

    This script does NOT install Equalizer APO, does NOT change which
    Windows audio devices APO is attached to, and does NOT touch
    Discord, Windows system audio, Chrome, Spotify, or the HyperX
    microphone. Device scoping is set once at APO install time (or via
    the Equalizer APO Configurator) - this script only edits filter
    text in a config file APO already owns.

    Equalizer APO reloads config.txt automatically on save. No process
    restart, no audio engine restart, no added latency from running
    this script - it is a text write, nothing more.

.NOTES
    Keep v1, v2, and off untouched. This is a new, separate profile.
    A timestamped backup of the config file is written before any
    change, every time this script runs.
#>

$ErrorActionPreference = "Stop"

$ElgatoEndpointGuid = "{2c1698c1-ea24-4e48-b5d5-3f23da2cc025}"
$ProfileName = "v3-competitive"

# --- Locate the Equalizer APO config folder ---
$apoRoot = "$Env:ProgramFiles\EqualizerAPO\config"
if (-not (Test-Path $apoRoot)) {
    $apoRoot = "${Env:ProgramFiles(x86)}\EqualizerAPO\config"
}
if (-not (Test-Path $apoRoot)) {
    Write-Host "ERROR: Could not find an Equalizer APO config folder under Program Files." -ForegroundColor Red
    Write-Host "Confirm Equalizer APO is installed before running this script." -ForegroundColor Red
    exit 1
}

# --- Prefer a per-device config if this install uses one, else the root config.txt ---
$perDevicePath = Join-Path $apoRoot "$ElgatoEndpointGuid\config.txt"
if (Test-Path $perDevicePath) {
    $configPath = $perDevicePath
} else {
    $configPath = Join-Path $apoRoot "config.txt"
}

if (-not (Test-Path $configPath)) {
    Write-Host "ERROR: No config.txt found at $configPath" -ForegroundColor Red
    Write-Host "Verify Equalizer APO is installed and scoped to the Elgato 4K X endpoint before running this script." -ForegroundColor Red
    exit 1
}

# --- Back up current config before writing anything ---
$backupDir = Join-Path $apoRoot "backups"
if (-not (Test-Path $backupDir)) {
    New-Item -ItemType Directory -Path $backupDir | Out-Null
}
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$backupPath = Join-Path $backupDir "config-$timestamp-before-$ProfileName.txt"
Copy-Item -Path $configPath -Destination $backupPath -Force
Write-Host "Backed up current config to: $backupPath" -ForegroundColor DarkGray

# --- V3 filter set ---
$eqContent = @"
# ============================================================
# COD Audio EQ - PROFILE: V3 COMPETITIVE (Refined)
# Scope: Elgato 4K X capture endpoint ONLY ($ElgatoEndpointGuid)
# Applied: $timestamp
# Do NOT apply this file to Discord, Windows system audio, Chrome,
# Spotify, or the HyperX microphone endpoint.
# ============================================================

Preamp: -6.0 dB

Filter 1:  ON HPQ Fc 35 Hz Q 0.70
Filter 2:  ON PK  Fc 90 Hz    Gain -3.0 dB Q 0.80
Filter 3:  ON PK  Fc 150 Hz   Gain -1.0 dB Q 1.00
Filter 4:  ON PK  Fc 650 Hz   Gain  1.0 dB Q 1.00
Filter 5:  ON PK  Fc 850 Hz   Gain  1.3 dB Q 1.10
Filter 6:  ON PK  Fc 1800 Hz  Gain  2.0 dB Q 1.00
Filter 7:  ON PK  Fc 2700 Hz  Gain  2.5 dB Q 1.30
Filter 8:  ON PK  Fc 3400 Hz  Gain  3.0 dB Q 1.20
Filter 9:  ON PK  Fc 5200 Hz  Gain  2.0 dB Q 1.00
Filter 10: ON PK  Fc 7000 Hz  Gain  0.8 dB Q 1.10
Filter 11: ON PK  Fc 10000 Hz Gain -1.0 dB Q 0.70
"@

Set-Content -Path $configPath -Value $eqContent -Encoding UTF8

Write-Host ""
Write-Host "=========================================" -ForegroundColor Green
Write-Host "  COD AUDIO EQ: V3 COMPETITIVE - ACTIVE   " -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green
Write-Host "Config written to : $configPath"
Write-Host "Expected scope    : Elgato 4K X ($ElgatoEndpointGuid)"
Write-Host "Backup of prior config: $backupPath"
Write-Host "Equalizer APO applies changes live - no restart needed."
Write-Host ""
Write-Host "Verify scope any time: Windows Sound Control Panel > Recording tab >" -ForegroundColor DarkGray
Write-Host "Elgato 4K X > Properties > Enhancements/APO tab should be the only device listing Equalizer APO." -ForegroundColor DarkGray
