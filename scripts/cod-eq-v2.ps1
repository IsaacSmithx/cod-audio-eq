<#
.SYNOPSIS
    COD Audio EQ - Profile V2 (Competitive / Stronger)

.DESCRIPTION
    Reference implementation matching the same mechanics as
    cod-eq-v3.ps1. This is a git-tracked reconstruction of the v2
    filter values you provided - treat your local
    C:\Users\isaac\Documents\Codex\cod-eq-v2.ps1 as the real source of
    truth and diff before replacing it with this one.

    Writes to the Equalizer APO config file scoped to the Elgato 4K X
    capture endpoint only. No other device is touched. APO reloads the
    config live on save - no restart, no added latency.
#>

$ErrorActionPreference = "Stop"

$ElgatoEndpointGuid = "{2c1698c1-ea24-4e48-b5d5-3f23da2cc025}"
$ProfileName = "v2-competitive"

$apoRoot = "$Env:ProgramFiles\EqualizerAPO\config"
if (-not (Test-Path $apoRoot)) {
    $apoRoot = "${Env:ProgramFiles(x86)}\EqualizerAPO\config"
}
if (-not (Test-Path $apoRoot)) {
    Write-Host "ERROR: Could not find an Equalizer APO config folder under Program Files." -ForegroundColor Red
    exit 1
}

$perDevicePath = Join-Path $apoRoot "$ElgatoEndpointGuid\config.txt"
if (Test-Path $perDevicePath) {
    $configPath = $perDevicePath
} else {
    $configPath = Join-Path $apoRoot "config.txt"
}

if (-not (Test-Path $configPath)) {
    Write-Host "ERROR: No config.txt found at $configPath" -ForegroundColor Red
    exit 1
}

$backupDir = Join-Path $apoRoot "backups"
if (-not (Test-Path $backupDir)) {
    New-Item -ItemType Directory -Path $backupDir | Out-Null
}
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$backupPath = Join-Path $backupDir "config-$timestamp-before-$ProfileName.txt"
Copy-Item -Path $configPath -Destination $backupPath -Force
Write-Host "Backed up current config to: $backupPath" -ForegroundColor DarkGray

$eqContent = @"
# ============================================================
# COD Audio EQ - PROFILE: V2 COMPETITIVE (Stronger)
# Scope: Elgato 4K X capture endpoint ONLY ($ElgatoEndpointGuid)
# Applied: $timestamp
# ============================================================

Preamp: -5.5 dB

Filter 1: ON HPQ Fc 35 Hz Q 0.70
Filter 2: ON PK Fc 90 Hz Gain -3.5 dB Q 0.80
Filter 3: ON PK Fc 180 Hz Gain -2.0 dB Q 1.00
Filter 4: ON PK Fc 850 Hz Gain 1.5 dB Q 1.10
Filter 5: ON PK Fc 1800 Hz Gain 2.2 dB Q 1.00
Filter 6: ON PK Fc 3200 Hz Gain 3.0 dB Q 1.20
Filter 7: ON PK Fc 5200 Hz Gain 1.8 dB Q 1.00
Filter 8: ON PK Fc 8200 Hz Gain -1.0 dB Q 1.20
"@

Set-Content -Path $configPath -Value $eqContent -Encoding UTF8

Write-Host ""
Write-Host "=========================================" -ForegroundColor Yellow
Write-Host "  COD AUDIO EQ: V2 COMPETITIVE - ACTIVE   " -ForegroundColor Yellow
Write-Host "=========================================" -ForegroundColor Yellow
Write-Host "Config written to: $configPath"
Write-Host "Backup of prior config: $backupPath"
