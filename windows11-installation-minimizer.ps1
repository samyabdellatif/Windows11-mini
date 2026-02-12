param(
    [Parameter(Mandatory)]
    [string]$DriveLetter
)

$Sources = "$DriveLetter`:\sources"
$ESD = "$Sources\install.esd"
$WIM = "$Sources\install.wim"
$MountDir = "$env:TEMP\WIM_MOUNT"

if (!(Test-Path $ESD)) {
    Write-Error "install.esd not found. Unsupported media."
    exit 1
}

Write-Host "install.esd detected — converting to install.wim"

dism /Export-Image `
     /SourceImageFile:$ESD `
     /SourceIndex:1 `
     /DestinationImageFile:$WIM `
     /Compress:max `
     /CheckIntegrity

if (!(Test-Path $WIM)) {
    Write-Error "ESD → WIM conversion failed"
    exit 1
}

mkdir $MountDir -Force | Out-Null

Write-Host "Mounting install.wim..."
dism /Mount-Wim /WimFile:$WIM /Index:1 /MountDir:$MountDir /ReadWrite

$SystemHive   = "$MountDir\Windows\System32\Config\SYSTEM"
$SoftwareHive = "$MountDir\Windows\System32\Config\SOFTWARE"

reg load HKLM\OFF_SYS $SystemHive
reg load HKLM\OFF_SW  $SoftwareHive

Write-Host "Applying offline debloat policies..."

:: TELEMETRY
reg add "HKLM\OFF_SW\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f

:: DEFENDER
reg add "HKLM\OFF_SW\Policies\Microsoft\Windows Defender" /v DisableAntiSpyware /t REG_DWORD /d 1 /f

:: EDGE
reg add "HKLM\OFF_SW\Policies\Microsoft\EdgeUpdate" /v AutoUpdateCheckPeriodMinutes /t REG_DWORD /d 0 /f
reg add "HKLM\OFF_SW\Policies\Microsoft\EdgeUpdate" /v DisableAutoUpdateChecksCheckboxValue /t REG_DWORD /d 1 /f

:: ONEDRIVE
reg add "HKLM\OFF_SW\Policies\Microsoft\Windows\OneDrive" /v DisableFileSyncNGSC /t REG_DWORD /d 1 /f
reg add "HKLM\OFF_SW\Policies\Microsoft\Windows\OneDrive" /v PreventUsageOfOneDriveForFileStorage /t REG_DWORD /d 1 /f

:: TEAMS
reg add "HKLM\OFF_SW\Policies\Microsoft\Office\Teams" /v PreventInstallation /t REG_DWORD /d 1 /f

:: COPILOT
reg add "HKLM\OFF_SW\Policies\Microsoft\Windows\CloudExperienceHost" /v DisableCoprocessor /t REG_DWORD /d 1 /f

reg unload HKLM\OFF_SYS
reg unload HKLM\OFF_SW

Write-Host "Committing image..."
dism /Unmount-Wim /MountDir:$MountDir /Commit

Write-Host ""
Write-Host "SUCCESS:"
Write-Host "Rufus installer is now debloated."
Write-Host "Windows will install lightweight, no Edge/OneDrive/Teams/Copilot/Telemetry."
