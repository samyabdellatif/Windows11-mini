
# =====================================================
# Windows 11 Ultra-Minimal Runtime Workstation Script
# Purpose: Empty GUI host for arbitrary runtime apps
# =====================================================

Write-Host "Applying EMPTY GUI RUNTIME profile..." -ForegroundColor Cyan

# -----------------------------------------------------
# 1. Kill updates, servicing, delivery, maintenance
# -----------------------------------------------------
$updateServices = @(
    "wuauserv",
    "UsoSvc",
    "DoSvc",
    "WaaSMedicSvc"
)

foreach ($svc in $updateServices) {
    Stop-Service $svc -Force -ErrorAction SilentlyContinue
    Set-Service  $svc -StartupType Disabled -ErrorAction SilentlyContinue
}

# Disable maintenance tasks
schtasks /Change /TN "\Microsoft\Windows\TaskScheduler\Maintenance Configurator" /Disable 2>$null
schtasks /Change /TN "\Microsoft\Windows\TaskScheduler\Regular Maintenance" /Disable 2>$null

# -----------------------------------------------------
# 2. Kill telemetry, diagnostics, feedback
# -----------------------------------------------------
$telemetryServices = @(
    "DiagTrack",
    "dmwappushservice",
    "WerSvc"
)

foreach ($svc in $telemetryServices) {
    Stop-Service $svc -Force -ErrorAction SilentlyContinue
    Set-Service  $svc -StartupType Disabled -ErrorAction SilentlyContinue
}

New-Item "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Force | Out-Null
Set-ItemProperty `
 "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" `
 -Name AllowTelemetry -Type DWord -Value 0

# -----------------------------------------------------
# 3. Kill Defender COMPLETELY (runtime lab mode)
# -----------------------------------------------------
$defenderServices = @(
    "WinDefend",
    "WdNisSvc",
    "Sense"
)

foreach ($svc in $defenderServices) {
    Stop-Service $svc -Force -ErrorAction SilentlyContinue
    Set-Service  $svc -StartupType Disabled -ErrorAction SilentlyContinue
}

# Disable Defender features via registry (hard off)
New-Item "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" -Force | Out-Null
Set-ItemProperty `
 "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" `
 -Name DisableAntiSpyware -Type DWord -Value 1

# -----------------------------------------------------
# 4. Kill Search, indexing, prefetch, superfetch
# -----------------------------------------------------
$perfServices = @(
    "WSearch",
    "SysMain"
)

foreach ($svc in $perfServices) {
    Stop-Service $svc -Force -ErrorAction SilentlyContinue
    Set-Service  $svc -StartupType Disabled -ErrorAction SilentlyContinue
}

Set-ItemProperty `
 "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" `
 -Name EnablePrefetcher -Type DWord -Value 0

# -----------------------------------------------------
# 5. Reduce disk writes HARD
# -----------------------------------------------------

# Disable hibernation
powercfg /h off

# Disable last access time updates
fsutil behavior set disablelastaccess 1

# Reduce event log sizes (do not disable)
wevtutil sl Application /ms:524288
wevtutil sl System /ms:524288
wevtutil sl Security /ms:524288

# -----------------------------------------------------
# 6. Kill consumer / cloud / sync services
# -----------------------------------------------------
$cloudServices = @(
    "OneSyncSvc",
    "UserDataSvc",
    "UnistoreSvc",
    "CDPUserSvc",
    "MapsBroker",
    "RetailDemo"
)

foreach ($svc in $cloudServices) {
    Stop-Service $svc -Force -ErrorAction SilentlyContinue
    Set-Service  $svc -StartupType Disabled -ErrorAction SilentlyContinue
}

# -----------------------------------------------------
# 7. Kill devices you don't care about
# -----------------------------------------------------
$deviceServices = @(
    "Spooler",
    "Fax",
    "BluetoothUserService",
    "bthserv",
    "WiaRpc"
)

foreach ($svc in $deviceServices) {
    Stop-Service $svc -Force -ErrorAction SilentlyContinue
    Set-Service  $svc -StartupType Disabled -ErrorAction SilentlyContinue
}

# -----------------------------------------------------
# 8. Kill background apps & UWP runtime
# -----------------------------------------------------
$uwpServices = @(
    "AppXSvc",
    "ClipSVC",
    "LicenseManager"
)

foreach ($svc in $uwpServices) {
    Stop-Service $svc -Force -ErrorAction SilentlyContinue
    Set-Service  $svc -StartupType Disabled -ErrorAction SilentlyContinue
}

New-Item "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Force | Out-Null
Set-ItemProperty `
 "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" `
 -Name DisableWindowsConsumerFeatures -Type DWord -Value 1

# -----------------------------------------------------
# 9. Disable background app execution
# -----------------------------------------------------
New-Item "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" -Force | Out-Null
Set-ItemProperty `
 "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" `
 -Name GlobalUserDisabled -Type DWord -Value 1

# -----------------------------------------------------
# 10. Strip UI overhead
# -----------------------------------------------------
Set-ItemProperty `
 "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" `
 -Name VisualFXSetting -Type DWord -Value 2

# Disable widgets
New-Item "HKLM:\SOFTWARE\Policies\Microsoft\Dsh" -Force | Out-Null
Set-ItemProperty `
 "HKLM:\SOFTWARE\Policies\Microsoft\Dsh" `
 -Name AllowNewsAndInterests -Type DWord -Value 0

# -----------------------------------------------------
# DONE
# -----------------------------------------------------
Write-Host ""
Write-Host "=============================================" -ForegroundColor Green
Write-Host "EMPTY GUI RUNTIME PROFILE APPLIED" -ForegroundColor Green
Write-Host "Reboot REQUIRED" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Green
