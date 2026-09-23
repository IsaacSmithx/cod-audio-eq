<#
.SYNOPSIS
    COD Audio EQ - Profile OFF (Bypass)

.DESCRIPTION
    Reference implementation matching the same mechanics as
    cod-eq-v3.ps1. Writes a flat, unity-gain passthrough config so you
    can A/B against raw PS5 audio with zero EQ coloration.

    Writes to the Equalizer APO config file scoped to the Elgato 4K X
    capture endpoint only. No other device is touched.
#>

$ErrorActionPreference = "Stop"

$ElgatoEndpointGuid = "{2c1698c1-ea24-4e48-b5d5-3f23da2cc025}"
$ProfileName = "off-bypass"

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
# COD Audio EQ - PROFILE: OFF (Bypass)
# Scope: Elgato 4K X capture endpoint ONLY ($ElgatoEndpointGuid)
# Applied: $timestamp
# Flat passthrough - use this to A/B against every EQ profile.
# ============================================================

Preamp: 0.0 dB

Filter 1: OFF HPQ Fc 35 Hz Q 0.70
Filter 2: OFF PK Fc 90 Hz Gain 0.0 dB Q 0.80
Filter 3: OFF PK Fc 180 Hz Gain 0.0 dB Q 1.00
Filter 4: OFF PK Fc 850 Hz Gain 0.0 dB Q 1.10
Filter 5: OFF PK Fc 1800 Hz Gain 0.0 dB Q 1.00
Filter 6: OFF PK Fc 3200 Hz Gain 0.0 dB Q 1.20
Filter 7: OFF PK Fc 5200 Hz Gain 0.0 dB Q 1.00
Filter 8: OFF PK Fc 8200 Hz Gain 0.0 dB Q 1.20
"@

Set-Content -Path $configPath -Value $eqContent -Encoding UTF8

Write-Host ""
Write-Host "===================================" -ForegroundColor DarkGray
Write-Host "  COD AUDIO EQ: OFF / BYPASS - ACTIVE   " -ForegroundColor DarkGray
Write-Host "===================================" -ForegroundColor DarkGray
Write-Host "Config written to: $configPath"
Write-Host "Backup of prior config: $backupPath"
