FULL, SINGLE PowerShell SCRIPT that:
	•	🔻 Minimizes CPU
	•	🔻 Minimizes RAM
	•	🔻 Minimizes disk writes
	•	❌ Removes all safety assumptions
	•	❌ Disables updates, telemetry, recovery
	•	✅ Leaves Explorer + GUI + networking
	•	✅ Lets you run whatever binaries you want

This is as far as Windows 11 Pro can be pushed without replacing the kernel.

HOW TO USE:
- DOWNLOAD THE SCRIPT FILE 
- RUN POWERSHELL AS ADMIN
- change dir to file dir (CD <your download dir>) (or adjust the code below with file full path)
  
powershell.exe -ExecutionPolicy Bypass -File windows11-minimizer.ps1 

⸻

⚠️ VERY IMPORTANT
	•	Run as Administrator
	•	Expect no updates
	•	Expect no Defender protection
	•	Expect no crash recovery
	•	Expect logs to be useless
	•	Treat this OS as throwaway
	•	DO NOT USE ON IMPORTANT DATA

Reboot required at the end.


📊 WHAT YOU SHOULD EXPECT AFTER REBOOT

Idle system state
	•	🧠 RAM: ~1 – 2 GB
	•	🔧 Services: ~55–65
	•	💽 Disk writes: Near zero when idle
	•	🧵 CPU: Flat

What still works
	•	Explorer
	•	Desktop
	•	File dialogs
	•	Networking
	•	CMD / PowerShell
	•	Any EXE you run

What is DISABLED
	•	Updates
	•	Defender
	•	Recovery
	•	Store
	•	Logs
	•	Search
	•	Indexing
	•	Sync
	•	Telemetry

SOME OF THE SERVICES MAY NOT BE ALLOWED TO DISABLE DUE TO WINDOWS PROTECTION FOR RUNNING SYSTEM.

[WARNING]
#####################################
ONLY USE ON YOUR OWN RESPONSIBILTY AND IF YOU KNOW WHAT YOU'RE DOING.
DISABLING SOME SERVICES LIKE DEFENDER AND UPDATES CAN BE DANGEOURAS IN A WORK ENVIRONMENT.
#####################################

