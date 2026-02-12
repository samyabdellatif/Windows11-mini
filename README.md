# Windows 11 Empty GUI Runtime

## Overview

This PowerShell script aggressively minimizes Windows 11/10 Pro into a very lightweight system.

The goal is to make Windows behave like a disposable graphical process launcher rather than a general-purpose operating system.

This configuration is intended for lab machines, test benches, reverse engineering environments, CI runners, fuzzing stations, and similar controlled scenarios.

## The soul purpose is to let windows consume the least required resources (RAM, DISK read/writes, Processor) to allow more responsivness for anything else you run.

---

## Major Changes Applied

### System Services

- Windows Update and servicing disabled
- Telemetry and diagnostics disabled
- Windows Defender fully disabled
- Search, indexing, prefetch, and SysMain disabled
- Cloud, sync, consumer, and UWP services disabled
- Unused device services disabled

### Disk and Resource Reduction

- Hibernation disabled
- Last access time updates disabled
- Event log sizes reduced
- Background apps disabled
- Visual effects minimized

### UI and Runtime Behavior

- Widgets disabled
- Consumer features disabled
- Background execution restricted
- Explorer remains functional

---

## What Will No Longer Work

- Windows Update
- Microsoft Defender
- Microsoft Store
- Recovery and repair features
- Telemetry and diagnostics
- Search and indexing
- System maintenance tasks
- AppX and UWP apps
- Meaningful system logs

## I have tested it on several windows 11 installations and proven working without breaking anything. but use on your own risk, If something breaks, Windows will not fix itself.  no guarantees.

---

## Expected Idle System State

Typical values after reboot on Windows 11 Pro:

- RAM usage approximately 1 to 2 GB (windows only not including other apps you installed)
- Service count approximately 55 to 65
- Disk writes near zero when idle
- CPU usage flat at idle

Actual results depend on hardware, drivers and other software you have installed.

## Requirements

- Windows 11 Pro
- Administrator privileges
- PowerShell 5.1 or later
- Ability to reboot after execution

---

## How to Use

1. Clone or download this repository
2. Open an elevated PowerShell session
3. Allow script execution for the session
4. Run the script with verbose output
6. Reboot

Example:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
.\windows11-minimizer.ps1 -Verbose
```

## Debload a windows 11 USB installation drive (currently only working with RUFUS made USB)
- after preparing the bootable usb using rufus.
- use the following scrip (replace drive letter with your USB drive letter)
```powershell
powershell -ExecutionPolicy Bypass -File .\windows11-installation-minimizer.ps1 -DriveLetter D:
```
## It may take a while to stop some services. keep waiting it will eventually stop and gets disabled.

## Warnings and Disclaimers

- This script intentionally removes:

- Security protections

- Update mechanisms

- Recovery capabilities

- Stability guarantees

- Treat the resulting system as disposable.

## Do not run this on machines with valuable data.
## Do not expose the system to untrusted networks.
## Do not expect Microsoft support.

