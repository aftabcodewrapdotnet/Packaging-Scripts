# Create Packaging VM 🛠️

A PowerShell based provisioning script designed to create a clean-room Virtual Machine specifically for enterprise application packaging.

> ⚠️ **Risk Level: HIGH** > This is a highly destructive script designed **strictly** for fresh, clean-room Virtual machine preparation. It will remove software dependencies, permanently disable Windows Update, and purge existing device management clients (SCCM). Do not execute this on a production system.

---

## 🚀 Key Features

* **Environment Cleanup:** Automated removal of pre-existing Microsoft Visual C++ Redistributables (both x86 and x64),  disabling of Windows Update services (`wuauserv`, `bits`, `dosvc`, etc.), and cleanup of system caches ( e.g. `Temp`, `Prefetch`, `Logs`).
* **Client Management Removal:** Forcefully removes Configuration Manager/SCCM/MECM client (`ccmsetup.exe`).
* **Tools:** Uses Windows Package Manager (`winget`) to silently deploy Master Packager and Visual Studio Code with PowerShell Extension
* **MSI Editors:** Installs legacy MSI editors (Orca and instead)
* **SYSTEM Context:** Automatically populates a local `C:\Tools` utilities directory with core Sysinternals tools (suppressing EULAs via the registry) creates custom Start Menu entries to launch decoupled CMD or PowerShell CLI windows under the `NT AUTHORITY\SYSTEM` account.
* **Workspace :** Automatically generates standard local packaging folder structures (`C:\Working`, `C:\Installers`), forces the `EnableLinkedConnections` registry fix to ensure mapped drive visibility across varying UAC contexts, maps deployment shares, and pins them to File Explorer Quick Access.

---

## 📋 Prerequisites

Before running the script, ensure you have staged your offline installation binaries inside your source folder structured  as below:

* `C:\Packager Build\Tools\Orca\` (containing `Orca-x86_en-us.msi`)
* `C:\Packager Build\Tools\InstEd\` (containing the InstEd `.msi` package)
* `C:\Packager Build\Tools\ProcessExplorer\` (containing `procexp64.exe`)
* `C:\Packager Build\Tools\ProcessMonitor\` (containing `procmon64.exe`)
* `C:\Packager Build\Tools\PSTools\` (containing `psexec64.exe`)

---

## 🛠️ Configuration & Customization

Before executing or publishing, modify the configuration block near the top of the `BuildVM.ps1` script to match your network infrastructure:

```powershell
# --- CONFIGURATION (UPDATE THESE FOR YOUR ENVIRONMENT) ---
$NetworkShareServer = "\\YOUR-SERVER-NAME"
$VendorShare        = "$NetworkShareServer\ShareName\_VENDOR"
$PackagesShare      = "$NetworkShareServer\ShareName\Packages"
$VendorMediaShare   = "$NetworkShareServer\ShareName\VendorMedia"
$QuickAccessPaths   = @("$NetworkShareServer\ShareName\Packages", "$NetworkShareServer\ShareName\VendorMedia")


