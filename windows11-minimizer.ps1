param (
    [switch]$VerboseMode
)

if ($VerboseMode) {
    $VerbosePreference = "Continue"
}

Write-Host "Starting Empty GUI Runtime configuration"

$Summary = [ordered]@{
    ServicesStopped   = 0
    ServicesDisabled  = 0
    RegistryWrites    = 0
    TasksDisabled     = 0
    Errors            = 0
}

function Safe-StopService {
    param ($Name)

    try {
        $svc = Get-Service -Name $Name -ErrorAction Stop
        if ($svc.Status -ne "Stopped") {
            Stop-Service $Name -Force -ErrorAction Stop
            Write-Verbose "Service stopped: $Name"
            $Summary.ServicesStopped++
        }
        Set-Service $Name -StartupType Disabled -ErrorAction Stop
        Write-Verbose "Service disabled: $Name"
        $Summary.ServicesDisabled++
    }
    catch {
        Write-Warning "Failed to modify service: $Name"
        $Summary.Errors++
    }
}

function Safe-RegSet {
    param ($Path, $Name, $Type, $Value)

    try {
        if (-not (Test-Path $Path)) {
            New-Item $Path -Force | Out-Null
        }
        Set-ItemProperty -Path $Path -Name $Name -Type $Type -Value $Value
        Write-Verbose "Registry set: $Path $Name = $Value"
        $Summary.RegistryWrites++
    }
    catch {
        Write-Warning "Failed registry write: $Path $Name"
        $Summary.Errors++
    }
}

function Safe-DisableTask {
    param ($TaskName)

    try {
        schtasks /Change /TN $TaskName /Disable | Out-Null
        Write-Verbose "Task disabled: $TaskName"
        $Summary.TasksDisabled++
    }
    catch {
        Write-Warning "Failed to disable task: $TaskName"
        $Summary.Errors++
    }
}

Write-Host "Disabling update and servicing services"
"wuauserv","UsoSvc","DoSvc","WaaSMedicSvc" | ForEach-Object {
    Safe-StopService $_
}

Safe-DisableTask "\Microsoft\Windows\TaskScheduler\Maintenance Configurator"
Safe-DisableTask "\Microsoft\Windows\TaskScheduler\Regular Maintenance"

Write-Host "Disabling telemetry services"
"DiagTrack","dmwappushservice","WerSvc" | ForEach-Object {
    Safe-StopService $_
}

Safe-RegSet "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" `
            "AllowTelemetry" DWord 0

Write-Host "Disabling Defender services"
"WinDefend","WdNisSvc","Sense" | ForEach-Object {
    Safe-StopService $_
}

Safe-RegSet "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" `
            "DisableAntiSpyware" DWord 1

Write-Host "Disabling search and memory optimizers"
"WSearch","SysMain" | ForEach-Object {
    Safe-StopService $_
}

Safe-RegSet "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" `
            "EnablePrefetcher" DWord 0

Write-Host "Reducing disk activity"

try {
    powercfg /h off | Out-Null
    Write-Verbose "Hibernation disabled"
}
catch {
    Write-Warning "Failed to disable hibernation"
    $Summary.Errors++
}

try {
    fsutil behavior set disablelastaccess 1 | Out-Null
    Write-Verbose "Last access updates disabled"
}
catch {
    Write-Warning "Failed to disable last access updates"
    $Summary.Errors++
}

try {
    wevtutil sl Application /ms:524288
    wevtutil sl System /ms:524288
    wevtutil sl Security /ms:524288
    Write-Verbose "Event log sizes reduced"
}
catch {
    Write-Warning "Failed to resize event logs"
    $Summary.Errors++
}

Write-Host "Disabling cloud and consumer services"
"OneSyncSvc","UserDataSvc","UnistoreSvc","CDPUserSvc","MapsBroker","RetailDemo" | ForEach-Object {
    Safe-StopService $_
}

Write-Host "Disabling unused device services"
"Spooler","Fax","BluetoothUserService","bthserv","WiaRpc" | ForEach-Object {
    Safe-StopService $_
}

Write-Host "Disabling UWP runtime services"
"AppXSvc","ClipSVC","LicenseManager" | ForEach-Object {
    Safe-StopService $_
}

Safe-RegSet "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" `
            "DisableWindowsConsumerFeatures" DWord 1

Safe-RegSet "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" `
            "GlobalUserDisabled" DWord 1

Safe-RegSet "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" `
            "VisualFXSetting" DWord 2

Safe-RegSet "HKLM:\SOFTWARE\Policies\Microsoft\Dsh" `
            "AllowNewsAndInterests" DWord 0

Write-Host ""
Write-Host "Execution summary"
Write-Host "Services stopped  : $($Summary.ServicesStopped)"
Write-Host "Services disabled : $($Summary.ServicesDisabled)"
Write-Host "Registry writes   : $($Summary.RegistryWrites)"
Write-Host "Tasks disabled    : $($Summary.TasksDisabled)"
Write-Host "Errors            : $($Summary.Errors)"
Write-Host ""
Write-Host "Reboot is required for all changes to take effect"
