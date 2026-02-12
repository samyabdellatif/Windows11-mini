# Windows 11 Empty GUI Runtime

## Overview

This project provides a PowerShell script that aggressively minimizes Windows 11 Pro into a lightweight GUI runtime host.

The goal is to make Windows behave like a disposable graphical process launcher rather than a general-purpose operating system.

This configuration is intended for lab machines, test benches, reverse engineering environments, CI runners, fuzzing stations, and similar controlled scenarios.

This is not a hardening script.  
This is not a performance tweak script.  
This intentionally removes safety, durability, and servicing guarantees.

---

## What This Script Does

After execution and reboot, Windows is reduced to:

- Explorer-based desktop
- Basic GUI and file dialogs
- Networking
- CMD and PowerShell
- Ability to run arbitrary executables

Everything else is disabled or minimized.

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

If something breaks, Windows will not fix itself.

---

## Expected Idle System State

Typical values after reboot on Windows 11 Pro:

- RAM usage approximately 0.9 to 1.2 GB
- Service count approximately 55 to 65
- Disk writes near zero when idle
- CPU usage flat at idle

Actual results depend on hardware and drivers.

---

## Intended Use Cases

This configuration is suitable for:

- Malware analysis sandboxes
- Reverse engineering labs
- Game or engine test rigs
- Continuous integration runners
- Disposable virtual machines
- Embedded HMI style deployments
- Research environments

It is not suitable for daily use, production systems, or machines with important data.

---

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
5. Reboot

Example:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
.\windows11-minimizer.ps1 -Verbose
