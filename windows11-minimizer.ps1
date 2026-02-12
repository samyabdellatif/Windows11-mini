
# =====================================================
# Windows 11 Ultra-Minimal Runtime Workstation
# =====================================================

$Report = @{
    ServicesDisabled = @()
    ServicesNotFound = @()
    ServicesFailed   = @()
    RegistrySet      = @()
    RegistryFailed   = @()
    CommandsRun      = @()
    CommandsFailed   = @()
}

function Disable-ServiceSafe {
    param ([string]$Name)

    try {
        $svc = Get-Service -Name $Name -ErrorAction Stop

        if ($svc.Status -ne "Stopped") {
            Stop-Service $Name -Force -ErrorAction Stop
        }

        Set-Service $Name -StartupType Disabled -ErrorAction Stop
        $Report.ServicesDisabled += $Name
        Write-Host "[✓] Service disabled: $Name" -ForegroundColor Green
    }
    catch [System.InvalidOperationException] {
        $Report.ServicesNotFound += $Name
        Write-Host "[-] Service not found: $Name" -ForegroundColor DarkGray
    }
    catch {
        $Report.ServicesFailed += "$Name :: $($_.Exception.Message)"
        Write-Host "[x] Failed to disable service: $Name" -ForegroundColor Red
    }
}

function Set-RegistrySafe {
    param (
        [string]$Path,
        [string]$Name,
        [object]$Value,
        [Microsoft.Win32.RegistryValueKind]$Type
    )

    try {
        New-Item -Path $Path -Force -ErrorAction Stop | Out-Null
        Set-ItemProperty -Path $Path -Name $Name -Value $Value -Type $Type -ErrorAction Stop
        $Report.RegistrySet += "$Path\$Name"
        Write-Host "[✓] Registry set: $Path\$Name" -ForegroundColor Green
    }
    catch {
        $Report.RegistryFailed += "$Path\$Name :: $($_.Exception.Message)"
        Write-Host "[x] Registry failed: $Path\$Name" -ForegroundColor Red
    }
}

function Run-CommandSafe {
    param ([string]$Command)

    try {
        cmd.exe /c $Command | Out-Null
        $Report.CommandsRun += $Command
        Write-Host "[✓] Command executed: $Command" -ForegroundColor Green
    }
    catch {
        $Report.CommandsFailed += "$Command :: $($_.Exception.Message)"
        Write-Host "[x] Command failed: $Command" -ForegroundColor Red
    }
}

Write-Host "`nApplying EMPTY GUI RUNTIME profile (AUDITED)..." -ForegroundColor Cyan

# -----------------------------------------------------
# 1. Updates / Servicing
# -----------------------------------------------------
$updateServices = "wuauserv","UsoSvc","DoSvc","WaaSMedicSvc"
$updateServices | ForEach-Object { Disable-ServiceSafe $_ }

Run-CommandSafe 'schtasks /Change /TN "\Microsoft\Windows\TaskScheduler\Maintenance Configurator" /Disable'
Run-CommandSafe 'schtasks /Change /TN "\Microsoft\Windows\TaskScheduler\Regular Maintenance" /Disable'

# -----------------------------------------------------
# 2. Telemetry / Diagnostics
# -----------------------------------------------------
"DiagTrack","dmwappushservice","WerSvc" | ForEach-Object {
    Disable-ServiceSafe $_
}

Set-RegistrySafe `
 "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" `
 "AllowTelemetry" 0 DWord

# -----------------------------------------------------
# 3. Defender (hard off – lab mode)
# -----------------------------------------------------
"WinDefend","WdNisSvc","Sense" | ForEach-Object {
    Disable-ServiceSafe $_
}

Set-RegistrySafe `
 "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" `
 "DisableAntiSpyware" 1 DWord

# -----------------------------------------------------
# 4. Search / Prefetch / Superfetch
# -----------------------------------------------------
"WSearch","SysMain" | ForEach-Object {
    Disable-ServiceSafe $_
}

Set-RegistrySafe `
 "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" `
 "EnablePrefetcher" 0 DWord

# -----------------------------------------------------
# 5. Disk write minimization
# -----------------------------------------------------
Run-CommandSafe "powercfg /h off"
Run-CommandSafe "fsutil behavior set disablelastaccess 1"
Run-CommandSafe "wmic computersystem set AutomaticManagedPagefile=False"
Run-CommandSafe 'wmic pagefileset where name="C:\\pagefile.sys" set InitialSize=512,MaximumSize=512'
Run-CommandSafe "wevtutil sl Application /ms:524288"
Run-CommandSafe "wevtutil sl System /ms:524288"
Run-CommandSafe "wevtutil sl Security /ms:524288"

# -----------------------------------------------------
# 6. Cloud / Sync junk
# -----------------------------------------------------
"OneSyncSvc","UserDataSvc","UnistoreSvc","CDPUserSvc","MapsBroker","RetailDemo" |
    ForEach-Object { Disable-ServiceSafe $_ }

# -----------------------------------------------------
# 7. Devices
# -----------------------------------------------------
"Spooler","Fax","BluetoothUserService","bthserv","WiaRpc" |
    ForEach-Object { Disable-ServiceSafe $_ }

# -----------------------------------------------------
# 8. UWP runtime / background apps
# -----------------------------------------------------
"AppXSvc","ClipSVC","LicenseManager" |
    ForEach-Object { Disable-ServiceSafe $_ }

Set-RegistrySafe `
 "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" `
 "DisableWindowsConsumerFeatures" 1 DWord

Set-RegistrySafe `
 "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" `
 "GlobalUserDisabled" 1 DWord

# -----------------------------------------------------
# 9. UI overhead
# -----------------------------------------------------
Set-RegistrySafe `
 "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" `
 "VisualFXSetting" 2 DWord

Set-RegistrySafe `
 "HKLM:\SOFTWARE\Policies\Microsoft\Dsh" `
 "AllowNewsAndInterests" 0 DWord

# -----------------------------------------------------
# SUMMARY
# -----------------------------------------------------
Write-Host "`n================ SUMMARY ================" -ForegroundColor Cyan
Write-Host "Services disabled : $($Report.ServicesDisabled.Count)"
Write-Host "Services not found: $($Report.ServicesNotFound.Count)"
Write-Host "Services failed   : $($Report.ServicesFailed.Count)"
Write-Host "Registry set      : $($Report.RegistrySet.Count)"
Write-Host "Registry failed   : $($Report.RegistryFailed.Count)"
Write-Host "Commands executed : $($Report.CommandsRun.Count)"
Write-Host "Commands failed   : $($Report.CommandsFailed.Count)"
Write-Host "========================================" -ForegroundColor Cyan

Write-Host "`nREBOOT REQUIRED" -ForegroundColor Green
