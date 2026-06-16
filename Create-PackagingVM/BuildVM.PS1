<#
.SYNOPSIS
    Physical Packaging VM Build Script
    
.DESCRIPTION
    1. Uninstalls all Microsoft Visual C++ Redistributables 
    2. Disables Windows Update service
    3. Uninstalls the SCCM/ConfigMgr client
    4. Installs Orca MSI Editor
    5. Installs InstEd MSI Editor
    6. Cleans Temp directories
    7. Installs Master Packager
    8. Installs VS Code and PowerShell Extension 
    9. Setup Sysinternals Folders & SYSTEM Shortcuts to run CMD and PowerShell as SYSTEM
    10. Copies custom packaging utility scripts (WIM, Mount, Install/Uninstall) to C:\Tools
    11. Creates Local Working Directories (C:\Installers, C:\Working)
    12. Copies Packaging Template from a network share
    13. Configures EnableLinkedConnections registry fix for drive visibility
    14. Maps Package source and installer source locations and pins to Quick Access
    15. Removes the temporary "Packager Build" setup folder

.NOTES
    Author: Aftab Khan
    Date: May 2026
    Risk: HIGH - Destructive script intended for clean-room VM preparation only.
#>

# --- CONFIGURATION (UPDATE THESE FOR YOUR ENVIRONMENT) ---
$NetworkShareServer = "\\YOUR-SERVER-NAME"
$VendorShare        = "$NetworkShareServer\ShareName\_VENDOR"
$PackagesShare      = "$NetworkShareServer\ShareName\Packages"
$VendorMediaShare   = "$NetworkShareServer\ShareName\VendorMedia"
$QuickAccessPaths   = @("$NetworkShareServer\ShareName\Packages", "$NetworkShareServer\ShareName\VendorMedia")

# Ensure script is running as Admin
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "Please run this script as an Administrator."
    exit
}

# --- STEP 1: REMOVE VISUAL C++ REDISTRIBUTABLES ---
Write-Host ">>> Removing Visual C++ Redistributables..." -ForegroundColor Cyan
$Paths = @("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*", "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*")
$VCList = Get-ItemProperty $Paths | Where-Object { $_.DisplayName -like "*Microsoft Visual C++*" }
foreach ($pkg in $VCList) {
    if ($pkg.UninstallString) {
        Write-Host "Uninstalling: $($pkg.DisplayName)" -ForegroundColor Yellow
        if ($pkg.UninstallString -match "MsiExec.exe") {
            $Guid = ([regex]'{[A-F0-9-]+}').Match($pkg.UninstallString).Value
            if ($Guid) { Start-Process -FilePath "msiexec.exe" -ArgumentList "/x $Guid /qn /norestart" -Wait }
        } else {
            $UninstPath = ($pkg.UninstallString -split '(?<=.exe"?)')[0].Replace('"','')
            $UninstArgs = ($pkg.UninstallString -split '(?<=.exe"?)')[1..-1] + " /uninstall /quiet /norestart"
            if (Test-Path $UninstPath) { Start-Process -FilePath $UninstPath -ArgumentList $UninstArgs -Wait }
        }
    }
}

# --- STEP 2: STOP WINDOWS UPDATES ---
Write-Host "`n>>> Disabling Windows Update Services..." -ForegroundColor Cyan
$Services = @("wuauserv", "bits", "dosvc", "WaaSMedicSvc", "UsoSvc")
foreach ($SvcName in $Services) {
    Stop-Service -Name $SvcName -Force -ErrorAction SilentlyContinue
    & sc.exe config $SvcName start= disabled | Out-Null
}
$WUKey = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"
if (-not (Test-Path $WUKey)) { New-Item -Path $WUKey -Force | Out-Null }
Set-ItemProperty -Path $WUKey -Name "NoAutoUpdate" -Value 1 -Type DWord

# --- STEP 3: UNINSTALL SCCM CLIENT ---
Write-Host "`n>>> Checking for SCCM Client..." -ForegroundColor Cyan
$CCMSetup = "$env:SystemRoot\ccmsetup\ccmsetup.exe"
if (Test-Path $CCMSetup) {
    Start-Process -FilePath $CCMSetup -ArgumentList "/uninstall" -Wait
    Start-Sleep -Seconds 10
}

# --- STEP 4 & 5: INSTALL MSI EDITORS ---
Write-Host "`n>>> Installing MSI Editors..." -ForegroundColor Cyan
$OrcaSource = "C:\Packager Build\Tools\Orca\Orca-x86_en-us.msi"
if (Test-Path $OrcaSource) { Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$OrcaSource`" /qn /norestart" -Wait }
$InstEdSource = Get-ChildItem -Path "C:\Packager Build\Tools\InstEd" -Filter "*.msi" | Select-Object -ExpandProperty FullName -First 1
if ($InstEdSource) { Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$InstEdSource`" /qn /norestart" -Wait }

# --- STEP 6: CLEANUP Folders ---
Write-Host "`n>>> Wiping temporary system files..." -ForegroundColor Cyan
$CleanupPaths = @("$env:TEMP\*", "C:\Windows\Temp\*", "C:\Windows\Prefetch\*", "C:\Windows\Logs\*")
foreach ($Path in $CleanupPaths) { Remove-Item -Path $Path -Recurse -Force -ErrorAction SilentlyContinue }

# --- STEP 7: INSTALL MASTER PACKAGER ---
Write-Host "`n>>> Installing Master Packager..." -ForegroundColor Cyan
winget install --id MasterPackager.MasterPackager -e --source winget --accept-source-agreements --accept-package-agreements
$MPKey = "HKCU:\Software\Master Packager\Master Packager"
if (-not (Test-Path $MPKey)) { New-Item -Path $MPKey -Force | Out-Null }
Set-ItemProperty -Path $MPKey -Name "CheckForUpdates" -Value 0 -Type DWord

# --- STEP 8: INSTALL VS CODE AND POWERSHELL EXTENSION ---
Write-Host "`n>>> Installing VS Code and Extensions..." -ForegroundColor Cyan
winget install --id Microsoft.VisualStudioCode -e --scope machine --source winget --accept-source-agreements --accept-package-agreements
$SysCode = "C:\Program Files\Microsoft VS Code\bin\code.cmd"
$UsrCode = "$env:LocalAppData\Programs\Microsoft VS Code\bin\code.cmd"
$CodeBin = if (Test-Path $SysCode) { $SysCode } else { $UsrCode }
if (Test-Path $CodeBin) { Start-Process -FilePath $CodeBin -ArgumentList "--install-extension ms-vscode.PowerShell" -Wait }

# --- STEP 9: SETUP TOOLS SHORTCUTS ---
Write-Host "`n>>> Setting up Tools and SYSTEM Shortcuts..." -ForegroundColor Cyan
$ToolDir = "C:\Tools"
if (-not (Test-Path $ToolDir)) { New-Item -Path $ToolDir -ItemType Directory | Out-Null }
$SysSource = "C:\Packager Build\Tools"
@("ProcessExplorer", "ProcessMonitor", "PSTools") | ForEach-Object { Copy-Item -Path (Join-Path $SysSource $_) -Destination $ToolDir -Recurse -Force }

$PsExec = "$ToolDir\PSTools\psexec64.exe"
$ProcExp = "$ToolDir\ProcessExplorer\procexp64.exe"
$ProcMon = "$ToolDir\ProcessMonitor\procmon64.exe"

# Suppress Sysinternals EULAs
$EulaPaths = @(
    "HKCU:\Software\Sysinternals",
    "HKCU:\Software\Sysinternals\Process Explorer",
    "HKCU:\Software\Sysinternals\Process Explorer 64",
    "HKCU:\Software\Sysinternals\Process Monitor",
    "HKCU:\Software\Sysinternals\Process Monitor 64",
    "HKCU:\Software\Sysinternals\PsExec",
    "HKCU:\Software\Sysinternals\PsExec 64"
)
foreach ($P in $EulaPaths) {
    if (-not (Test-Path $P)) { New-Item -Path $P -Force | Out-Null }
    Set-ItemProperty -Path $P -Name "EulaAccepted" -Value 1 -Type DWord -ErrorAction SilentlyContinue
}

try {
    $WshShell = New-Object -ComObject WScript.Shell
    $StartMenu = "$env:ProgramData\Microsoft\Windows\Start Menu\Programs"
    $Shortcuts = @(
        @{ Name = "Process Explorer"; Target = $ProcExp; Args = ""; Icon = "$ProcExp, 0" },
        @{ Name = "Process Monitor"; Target = $ProcMon; Args = ""; Icon = "$ProcMon, 0" },
        @{ Name = "CMD as SYSTEM"; Target = $PsExec; Args = "-i -s -d cmd.exe"; Icon = "cmd.exe, 0" },
        @{ Name = "PowerShell as SYSTEM"; Target = $PsExec; Args = "-i -s -d powershell.exe"; Icon = "powershell.exe, 0" }
    )
    foreach ($lnk in $Shortcuts) {
        $Path = "$StartMenu\$($lnk.Name).lnk"
        $Shortcut = $WshShell.CreateShortcut($Path)
        $Shortcut.TargetPath = $lnk.Target; $Shortcut.Arguments = $lnk.Args; $Shortcut.IconLocation = $lnk.Icon; $Shortcut.Save()
        $bytes = [System.IO.File]::ReadAllBytes($Path); $bytes[0x15] = $bytes[0x15] -bor 0x20; [System.IO.File]::WriteAllBytes($Path, $bytes)
    }
} catch { }

# --- STEP 10: SCRIPTS ---
Write-Host "`n>>> Copying Utility Scripts to C:\Tools..." -ForegroundColor Cyan
@("Create wim.ps1", "quickmount.ps1", "install.cmd", "uninstall.cmd") | ForEach-Object { 
    $S = Join-Path $SysSource $_; if (Test-Path $S) { Copy-Item -Path $S -Destination $ToolDir -Force } 
}

# --- STEP 11 & 12: SHARE and TEMPLATE ---
Write-Host "`n>>> Creating Packaging Dirs and Copying Template..." -ForegroundColor Cyan
@("C:\Installers", "C:\Working") | ForEach-Object { if (-not (Test-Path $_)) { New-Item -Path $_ -ItemType Directory | Out-Null } }
$LocalDest = "C:\Physical packaging template"
if (Test-Path $VendorShare) { Copy-Item -Path $VendorShare -Destination $LocalDest -Recurse -Force -ErrorAction SilentlyContinue }

# --- STEP 13: DRIVE MAPPING ---
Write-Host "`n>>> Applying Registry Fix for Drive visibility..." -ForegroundColor Cyan
$LinkKey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
Set-ItemProperty -Path $LinkKey -Name "EnableLinkedConnections" -Value 1 -Type DWord -ErrorAction SilentlyContinue

Write-Host ">>> Mapping Network Drives..." -ForegroundColor Cyan
$DriveMaps = @(
    @{ Drive = "P:"; Path = $PackagesShare },
    @{ Drive = "V:"; Path = $VendorMediaShare }
)
foreach ($Map in $DriveMaps) {
    if (Test-Path $Map.Drive) { & net use $Map.Drive /delete /y | Out-Null }
    & net use $Map.Drive $Map.Path /persistent:yes | Out-Null
}

try {
    $QA = New-Object -ComObject Shell.Application
    $QuickAccessPaths | ForEach-Object {
        if (Test-Path $_) { $QA.Namespace($_).Self.InvokeVerb("pintohome") }
    }
} catch { }

# --- STEP 14 & 15: CLEANUP ---
Write-Host "`n>>> Final Cleanup: Removing Packager Build Folder..." -ForegroundColor Cyan
if (Test-Path "C:\Packager Build") {
    Set-Location C:\
    Start-Sleep -Seconds 2
    Remove-Item -Path "C:\Packager Build" -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Host "`n[PREP COMPLETE] Reboot and Happy Packaging!!!" -ForegroundColor Magenta -BackgroundColor White
