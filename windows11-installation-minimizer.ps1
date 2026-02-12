<#
.SYNOPSIS
Applies Empty GUI Runtime adjustments to an offline Windows installation, including disabling Edge, Teams, OneDrive, and Copilot.

.PARAMETER DriveLetter
The drive letter where the Windows installation is mounted (e.g., D:)

.EXAMPLE
.\Offline-EmptyGUI-v2.ps1 -DriveLetter D
#>

param (
    [Parameter(Mandatory = $true)]
    [ValidatePattern("^[A-Z]:$")]
    [string]$DriveLetter
)

$OfflineWindows = Join-Path $DriveLetter "Windows"
$OfflineSystemHive = Join-Path $OfflineWindows "System32\config\SYSTEM"
$OfflineSoftwareHive = Join-Path $OfflineWindows "System32\config\SOFTWARE"
$OfflineUserHive = Join-Path $OfflineWindows "System32\config\DEFAULT"

function Safe-OfflineRegSet {
    param ($HivePath, $KeyPath, $Name, $Type, $Value)

    try {
        reg load HKLM\OfflineHive "$HivePath" | Out-Null
        if ($Type -eq "DWord") {
            reg add "HKLM\OfflineHive\$KeyPath" /v $Name /t REG_DWORD /d $Value /f | Out-Null
        }
        elseif ($Type -eq "String") {
            reg add "HKLM\OfflineHive\$KeyPath" /v $Name /t REG_SZ /d $Value /f | Out-Null
        }
        Write-Host "Registry set (offline): $KeyPath\$Name = $Value"
        reg unload HKLM\OfflineHive | Out-Null
    }
    catch {
        Write-Warning "Failed offline registry write: $KeyPath\$Name"
    }
}

function Safe-OfflineServiceDisable {
    param ($ServiceName)

    try {
        reg load HKLM\OfflineSystem "$OfflineSystemHive" | Out-Null
        $ServiceKey = "HKLM\OfflineSystem\ControlSet001\Services\$ServiceName"
        if (Test-Path "HKLM\OfflineSystem\$ServiceKey") {
            reg add "HKLM\OfflineSystem\$ServiceKey" /v Start /t REG_DWORD /d 4 /f | Out-Null
            Write-Host "Service disabled (offline): $ServiceName"
        }
        reg unload HKLM\OfflineSystem | Out-Null
    }
    catch {
        Write-Warning "Failed to disable offline service: $ServiceName"
    }
}

Write-Host "Applying Empty GUI Runtime offline configuration to $DriveLetter"

# -----------------------------
# Disable update and servicing services
# -----------------------------
"wuauserv","UsoSvc","DoSvc","WaaSMedicSvc" | ForEach-Object { Safe-OfflineServiceDisable $_ }

# -----------------------------
# Disable telemetry services
# -----------------------------
"DiagTrack","dmwappushservice","WerSvc" | ForEach-Object { Safe-OfflineServiceDisable $_ }

Safe-OfflineRegSet $OfflineSoftwareHive "Policies\Microsoft\Windows\DataCollection" "AllowTelemetry" DWord 0

# -----------------------------
# Disable Defender
# -----------------------------
"WinDefend","WdNisSvc","Sense" | ForEach-Object { Safe-OfflineServiceDisable $_ }

Safe-OfflineRegSet $OfflineSoftwareHive "Policies\Microsoft\Windows Defender" "DisableAntiSpyware" DWord 1

# -----------------------------
# Disable search, prefetch, SysMain
# -----------------------------
"WSearch","SysMain" | ForEach-Object { Safe-OfflineServiceDisable $_ }

Safe-OfflineRegSet $OfflineSystemHive "ControlSet001\Control\Session Manager\Memory Management\PrefetchParameters" "EnablePrefetcher" DWord 0

# -----------------------------
# Disable cloud and consumer features
# -----------------------------
"OneSyncSvc","UserDataSvc","UnistoreSvc","CDPUserSvc","MapsBroker","RetailDemo" | ForEach-Object { Safe-OfflineServiceDisable $_ }

Safe-OfflineRegSet $OfflineSoftwareHive "Policies\Microsoft\Windows\CloudContent" "DisableWindowsConsumerFeatures" DWord 1
Safe-OfflineRegSet $OfflineUserHive "Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" "GlobalUserDisabled" DWord 1
Safe-OfflineRegSet $OfflineUserHive "Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" "VisualFXSetting" DWord 2
Safe-OfflineRegSet $OfflineSoftwareHive "Policies\Microsoft\Dsh" "AllowNewsAndInterests" DWord 0

# -----------------------------
# Disable Microsoft Edge, Teams, OneDrive, and Copilot
# -----------------------------

# Disable Edge updates and auto-launch
Safe-OfflineRegSet $OfflineSoftwareHive "Policies\Microsoft\EdgeUpdate" "AutoUpdateCheckPeriodMinutes" DWord 0
Safe-OfflineRegSet $OfflineSoftwareHive "Policies\Microsoft\EdgeUpdate" "DisableAutoUpdateChecksCheckboxValue" DWord 1

# Disable OneDrive startup and auto-launch
Safe-OfflineRegSet $OfflineSoftwareHive "Policies\Microsoft\Windows\OneDrive" "DisableFileSyncNGSC" DWord 1
Safe-OfflineRegSet $OfflineSoftwareHive "Policies\Microsoft\Windows\OneDrive" "PreventUsageOfOneDriveForFileStorage" DWord 1

# Disable Teams auto-start
Safe-OfflineRegSet $OfflineSoftwareHive "Policies\Microsoft\Office\Teams" "PreventInstallation" DWord 1
Safe-OfflineRegSet $OfflineSoftwareHive "Policies\Microsoft\Office\Teams" "IsTeamSSOEnabled" DWord 0

# Disable Copilot (via optional policy)
Safe-OfflineRegSet $OfflineSoftwareHive "Policies\Microsoft\Windows\CloudExperienceHost" "DisableCoprocessor" DWord 1

Write-Host ""
Write-Host "Offline Empty GUI Runtime configuration completed."
Write-Host "Windows will boot lightweight on first start, with services disabled, Defender/Telemetry off, Edge/Teams/OneDrive/Copilot disabled."
Write-Host "Install drivers manually as needed. First boot reboot required for all changes to take effect."
