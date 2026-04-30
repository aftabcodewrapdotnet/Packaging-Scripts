<#

.SYNOPSIS
PSAppDeployToolkit - This script performs the installation or uninstallation of an application(s).

.DESCRIPTION
- The script is provided as a template to perform an install, uninstall, or repair of an application(s).
- The script either performs an "Install", "Uninstall", or "Repair" deployment type.
- The install deployment type is broken down into 3 main sections/phases: Pre-Install, Install, and Post-Install.

The script imports the PSAppDeployToolkit module which contains the logic and functions required to install or uninstall an application.

PSAppDeployToolkit is licensed under the GNU LGPLv3 License - (C) 2025 PSAppDeployToolkit Team (Sean Lillis, Dan Cunningham, Muhammad Mashwani, Mitch Richters, Dan Gough).

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Lesser General Public License as published by the
Free Software Foundation, either version 3 of the License, or any later version. This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License
for more details. You should have received a copy of the GNU Lesser General Public License along with this program. If not, see <http://www.gnu.org/licenses/>.

.PARAMETER DeploymentType
The type of deployment to perform.

.PARAMETER DeployMode
Specifies whether the installation should be run in Interactive (shows dialogs), Silent (no dialogs), or NonInteractive (dialogs without prompts) mode.

NonInteractive mode is automatically set if it is detected that the process is not user interactive.

.PARAMETER AllowRebootPassThru
Allows the 3010 return code (requires restart) to be passed back to the parent process (e.g. SCCM) if detected from an installation. If 3010 is passed back to SCCM, a reboot prompt will be triggered.

.PARAMETER TerminalServerMode
Changes to "user install mode" and back to "user execute mode" for installing/uninstalling applications for Remote Desktop Session Hosts/Citrix servers.

.PARAMETER DisableLogging
Disables logging to file for the script.

.EXAMPLE
powershell.exe -File Invoke-AppDeployToolkit.ps1 -DeployMode Silent

.EXAMPLE
powershell.exe -File Invoke-AppDeployToolkit.ps1 -AllowRebootPassThru

.EXAMPLE
powershell.exe -File Invoke-AppDeployToolkit.ps1 -DeploymentType Uninstall

.EXAMPLE
Invoke-AppDeployToolkit.exe -DeploymentType "Install" -DeployMode "Silent"

.INPUTS
None. You cannot pipe objects to this script.

.OUTPUTS
None. This script does not generate any output.

.NOTES
Toolkit Exit Code Ranges:
- 60000 - 68999: Reserved for built-in exit codes in Invoke-AppDeployToolkit.ps1, and Invoke-AppDeployToolkit.exe
- 69000 - 69999: Recommended for user customized exit codes in Invoke-AppDeployToolkit.ps1
- 70000 - 79999: Recommended for user customized exit codes in PSAppDeployToolkit.Extensions module.

.LINK
https://psappdeploytoolkit.com

#>

[CmdletBinding()]
param
(
    [Parameter(Mandatory = $false)]
    [ValidateSet('Install', 'Uninstall', 'Repair')]
    [PSDefaultValue(Help = 'Install', Value = 'Install')]
    [System.String]$DeploymentType,

    [Parameter(Mandatory = $false)]
    [ValidateSet('Interactive', 'Silent', 'NonInteractive')]
    [PSDefaultValue(Help = 'Interactive', Value = 'Interactive')]
    [System.String]$DeployMode,

    [Parameter(Mandatory = $false)]
    [System.Management.Automation.SwitchParameter]$AllowRebootPassThru,

    [Parameter(Mandatory = $false)]
    [System.Management.Automation.SwitchParameter]$TerminalServerMode,

    [Parameter(Mandatory = $false)]
    [System.Management.Automation.SwitchParameter]$DisableLogging
)


##================================================
## MARK: Variables
##================================================

$adtSession = @{
    # App variables.
    #** Used for Logging and Audit Keys
    #** The new script does not need $ in front of variable Name
    AppVendor = 'NI'                     #** String Text, No special characters
    AppName = 'LabVIEW 2025 Q3'                  #** String Text, No special characters
    AppVersion = '25.3.2f2'                        #** String Text, No special characters
    AppArch = 'x64'                               #** Application type x86, x64
    AppLang = 'EN'
    AppRevision = '01'
    AppSuccessExitCodes = @(0)
    AppRebootExitCodes = @(1641, 3010)
    AppScriptVersion = '1.0.0'                    #** Revision of the script
    AppScriptDate = '2026-04-30'                  #** Todays Date, must be in yyyy-mm-dd format and use - NOT / or script will fail
    AppScriptAuthor = 'Codewrap.net'                 #** Packagers Name

    #** Audit Keys
	PackageName = 'NI_LabVIEW_2025_Q3'   #**Package Name
	AuditappArch = 'x64'                  #** the default AppArch has the <Spaces> removed by the toolkit module (options are 'x64','x86' or 'x86 and x64')
	appPatch = 'N/A'
	appTransform = 'N/A'
	InstalledBy = "$([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)"
	MSTDescriptor = 'N/A'
	ProductCode = 'N/A'
	TransformVersion = 'N/A'

    # Install Titles (Only set here to override defaults set by the toolkit).
    InstallName = ''
    InstallTitle = ''

    # Script variables.
    DeployAppScriptFriendlyName = $MyInvocation.MyCommand.Name
    DeployAppScriptVersion = '4.0.6'
    DeployAppScriptParameters = $PSBoundParameters
}

function Install-ADTDeployment
{
    ##================================================
    ## MARK: Pre-Install
    ##================================================
    $adtSession.InstallPhase = "Pre-$($adtSession.DeploymentType)"


    #**     CloseApps '<exe name>=<Friendly Name>'        Prompts to closes the applications listed, if silent install closes the app with no prompt
    #**     BlockExecution                                Prevents application specified in the CloseApps from running during the installation


    ## Show Welcome Message, close Internet Explorer if required, allow up to 3 deferrals, verify there is enough disk space to complete the install, and persist the prompt.
    #** Show-ADTInstallationWelcome -CloseProcesses iexplore -AllowDefer -DeferTimes 3 -CheckDiskSpace -PersistPrompt

    ## Show Progress Message (with the default message).
    #** Changing the value of -StatusMessage for a custom message 
    Show-ADTInstallationProgress -StatusMessage "Installation of $($adtSession.AppName) in progress. Please wait..." 


    ## <Perform Pre-Installation tasks here>


    ##================================================
    ## MARK: Install
    ##================================================
    $adtSession.InstallPhase = $adtSession.DeploymentType

    ## Handle Zero-Config MSI installations.
    if ($adtSession.UseDefaultMsi)
    {
        $ExecuteDefaultMSISplat = @{ Action = $adtSession.DeploymentType; FilePath = $adtSession.DefaultMsiFile }
        if ($adtSession.DefaultMstFile)
        {
            $ExecuteDefaultMSISplat.Add('Transform', $adtSession.DefaultMstFile)
        }
        Start-ADTMsiProcess @ExecuteDefaultMSISplat
        if ($adtSession.DefaultMspFiles)
        {
            $adtSession.DefaultMspFiles | Start-ADTMsiProcess -Action Patch
        }
    }

    ## <Perform Installation tasks here>

    #** ========================================================
    #** MODIFY THIS SECTION WITH YOUR REQUIRED INSTALL STEPS
    #** ========================================================

    #** ----------------------------------
    #**  Useful built in variables
    #**  $envProgramFiles           ~ 64bit Program Files
    #**  $envProgramFilesX86        ~ 32bit Program Files
    #**  $envProgramData            ~ ProgramData Folder
    #**  $envSystemDrive            ~ System Drive e.g. C:
    #**  $envWinDir                 ~ Windows Folder
    #** ----------------------------------

    <#
.SYNOPSIS
    LabVIEW 2025 Q3 Install script (WIM-Based)
    
    1. MOUNT:   Attaches LabVIEW LabVIEW_2025_Q3_25.3.2f2_x64_P1.wim to C:\MountPath
    2. NIPM:    Installs NI Package Manager core engine
    3. FEED:    Registers the mounted directory as a local source
    4. INSTALL: Triggers core installation
    5. LICENSE: Activates software by pointing to YOUR_LICENSE_SERVER:27000
    6. CLEAN:   Unmounts the WIM, purges C:\MountPath, and maps NI exit codes to SCCM 3010.
    7. SHORTCUTS: Clean up shortcuts
    8. FINAL RESULT: Check final result 
    9. FINAL BITS: Final tasks, registry 
#>
  
  
  ## --- STAGE 1: Mount wim and check for dodgy mounts! ---
$MountPath = "C:\MountPath"
$MountDir = "C:\MountPath"
$WimPath = Join-Path -Path $adtSession.DirFiles -ChildPath "LabVIEW_2025_Q3_25.3.2f2_x64_P1.wim"

Write-Host "Stage 1: Checking for stale mounts from previous interrupted attempts..." -ForegroundColor Cyan

# 1. Force-kill any lingering DISM processes
Get-Process -Name "dism" -ErrorAction SilentlyContinue | Stop-Process -Force

# 2. Query DISM for ANY image mounted
$staleMount = Get-WindowsImage -Mounted -ErrorAction SilentlyContinue | Where-Object { $_.MountPoint -eq $MountPath }

if ($staleMount) {
    Write-Host "Stale WIM detected on $MountPath. Forcing dismount..." -ForegroundColor Yellow
    & dism.exe /Unmount-Image /MountDir:$MountPath /Discard /CheckIntegrity
    
    # Clean up the DISM internal mount list
    & dism.exe /Cleanup-Mountpoints
    Start-Sleep -Seconds 5
}

# 3. If the folder exists but isn't 'mounted' >>> kill it!!!!
if (Test-Path $MountPath) {
    Write-Host "Cleaning up orphaned directory $MountPath..." -ForegroundColor Yellow
    Remove-Item -Path $MountPath -Recurse -Force -ErrorAction SilentlyContinue
}

# 4. Re-create a clean directory
if (!(Test-Path $MountPath)) {
    New-Item -ItemType Directory -Path $MountPath | Out-Null
}

# 5. Perform the fresh mount
try {
    Write-Host "Mounting WIM to $MountPath..." -ForegroundColor Yellow
    Mount-WindowsImage -ImagePath $WimPath -Index 1 -Path $MountPath -ReadOnly -ErrorAction Stop
} catch {
    Write-Host "CRITICAL ERROR: Failed to mount WIM even after cleanup." -ForegroundColor Red
    Write-Host "Error Detail: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# 6. Verify 
if (!(Test-Path "$MountPath\feeds")) {
    Write-Host "ERROR: Mount completed but 'feeds' folder is not visible. DISM session is unstable." -ForegroundColor Red
    exit 1
}

Write-Host "Stage 1 Complete: Environment is clean and WIM is mounted." -ForegroundColor Green 
 
 
## --- STAGE 2: NIPM ---
# This will run NIPackageManager25.5.0.exe from the files folder and not the MountPath
$NipmInstaller = Join-Path -Path $adtSession.DirFiles -ChildPath "NIPackageManager25.5.0.exe"

If (Test-Path $NipmInstaller) {
    Write-Host "Stage 2: Installing NIPM 25.5.0 from local source..." -ForegroundColor Cyan
    
    # Run the installer
    $nipmProcess = Start-Process -FilePath $NipmInstaller -ArgumentList "--quiet", "--accept-eulas", "--prevent-reboot" -Wait -PassThru
    
    Write-Host "NIPM engine installation finished with exit code: $($nipmProcess.ExitCode)" -ForegroundColor Green
} Else {
    Write-Host "ERROR: NIPM Installer not found at $NipmInstaller" -ForegroundColor Red
    exit 1
}
   
  
  ## --- STAGE 3: FEED  ---
$nipkg = "C:\Program Files\National Instruments\NI Package Manager\nipkg.exe"

# We all can do with a little sleep..!
Write-Host "Stage 3: Initializing NI Package Manager..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

# --- Wait for background mount to populate before proceeding ---
$feedPath = Join-Path -Path $MountPath -ChildPath "feeds\ni-labview-2025"
while (!(Test-Path $feedPath)) {
    Write-Host "Waiting for mount path to populate files..." -ForegroundColor Yellow
    Start-Sleep -Seconds 3
}

If (Test-Path $nipkg) {
    Write-Host "Stage 3: Registering local feed [LabVIEW2025]..." -ForegroundColor Cyan
    
    # Path to the feeds folder in $MountPath
    $feedPath = Join-Path -Path $MountPath -ChildPath "feeds\ni-labview-2025"
    
    # --- Check if feed already exists to prevent error on re-run!!! ---
    # Using Call Operator for reliability
    & "$nipkg" feed-list > "$env:TEMP\nipkg_feeds.txt"
    $existingFeeds = Get-Content "$env:TEMP\nipkg_feeds.txt"
    Remove-Item "$env:TEMP\nipkg_feeds.txt" -Force -ErrorAction SilentlyContinue

    If ($existingFeeds -match "LabVIEW2025") {
        Write-Host "Feed [LabVIEW2025] is already registered. Skipping add step..." -ForegroundColor Yellow
    } Else {
        # Register/Add the Feed
        & "$nipkg" feed-add --name=LabVIEW2025 """$feedPath"""
    }
    # --------------------------------------------------------------
    
    Write-Host "Updating package database..." -ForegroundColor Cyan
    & "$nipkg" update
    
    Write-Host "Feed registration complete." -ForegroundColor Green
} Else {
    Write-Host "ERROR: nipkg.exe not found. Re-check Stage 2 results." -ForegroundColor Red
    exit 1
}
 
 ## --- STAGE 4: Trigger the silent install ---
$nipkg = "C:\Program Files\National Instruments\NI Package Manager\nipkg.exe"

If (Test-Path $nipkg) {
    Write-Host "Stage 4: Triggering the silent install (Suppressing Reboot Warning)..." -ForegroundColor Cyan
    
    
    try {
        & "$nipkg" install ni-labview-2025-core-en --include-recommended -y --accept-eulas 2>$null
    } catch {
        Write-Host "Captured NI reboot warning. Proceeding to Stage 5..." -ForegroundColor Yellow
    }
    
    # Grab the code (-125071) for the final check
    $installExitCode = $LASTEXITCODE
    Write-Host "Installation process finished with exit code: $installExitCode" -ForegroundColor Yellow
} Else {
    Write-Host "ERROR: nipkg.exe not found. Cannot proceed with installation." -ForegroundColor Red
    exit 1
}


## --- STAGE 5: LICENSE ---
Write-Host "Stage 5: Activating LabVIEW via License Server..." -ForegroundColor Cyan

# Define path for the NI Licensing Command Line Tool
$niLicenseCmd = "C:\Program Files (x86)\National Instruments\Shared\License Manager\NILicensingCmd.exe"

If (Test-Path $niLicenseCmd) {
    # Point to server.co.uuk
    & "$niLicenseCmd" /addservers YOUR_LICENSE_SERVER:27000
    Write-Host "License server registration complete." -ForegroundColor Green
} Else {
    Write-Host "Warning: NILicensingCmd.exe not found. Activation skipped." -ForegroundColor Yellow
}


## --- STAGE 6: CLEAN ---
Write-Host "Stage 6: Dismounting LabVIEW WIM and cleaning up..." -ForegroundColor Cyan

# 1. Dismount the WIM
# Updated $MountDir to $MountPath to match Stage 1
Dismount-WindowsImage -Path $MountPath -Discard -ErrorAction SilentlyContinue

# 2. Check if the directory still exists
If (Test-Path $MountPath) {
    Write-Host "Removing temporary mount folder: $MountPath" -ForegroundColor Yellow
    # Recurse and Force!!
    Remove-Item -Path $MountPath -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Host "Stage 6: Clean up done." -ForegroundColor Green


## --- STAGE 7:Shortcuts ---
Write-Host "Stage 7: Removing unnecessary shortcuts and folders..." -ForegroundColor Cyan

$Shortcuts = @(
    "C:\Users\Public\Desktop\VI Package Manager (VIPM).lnk",
    "C:\Users\Public\Desktop\JKI Dragon.lnk",
    "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\National Instruments\NI Update Service.lnk",
    "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\National Instruments\NI Registration Wizard.lnk",
    "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\National Instruments\NI Customer Experience Improvement Program.lnk",
    "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\National Instruments\NI Error Reporting Settings.lnk"
    "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup\NI Error Reporting.lnk"
)

$Folders = @(
    "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\National Instruments\License Manager"
)

# 1. Remove specific shortcuts
foreach ($Shortcut in $Shortcuts) {
    if (Test-Path $Shortcut) {
        Write-Host "Removing shortcut: $Shortcut" -ForegroundColor Yellow
        Remove-Item -Path $Shortcut -Force -ErrorAction SilentlyContinue
    }
}

# 2. Remove folders
foreach ($Folder in $Folders) {
    if (Test-Path $Folder) {
        Write-Host "Removing folder: $Folder" -ForegroundColor Yellow
        Remove-Item -Path $Folder -Recurse -Force -ErrorAction SilentlyContinue
    }
}

Write-Host "Stage 7: Cleanup complete." -ForegroundColor Green


## --- STAGE 8: Create Audit Registry Keys ---
    Write-Host "Stage 8: Audit Keys..." -ForegroundColor Cyan

    # Path logic for 32-bit vs 64-bit
    If ($adtSession.AuditappArch -ne 'x64') {
        $RegPath = "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Audit\Software\$($adtSession.PackageName)"
    } Else {
        $RegPath = "HKEY_LOCAL_MACHINE\SOFTWARE\Audit\Software\$($adtSession.PackageName)"
    }

    # Stamp the Registry
    Set-ADTRegistryKey -Key $RegPath -Name 'Application Name' -Value $($adtSession.AppName) -Type String
    Set-ADTRegistryKey -Key $RegPath -Name 'Applied Patch' -Value $($adtSession.appPatch) -Type String
    Set-ADTRegistryKey -Key $RegPath -Name 'Applied Transforms' -Value $($adtSession.appTransform) -Type String
    Set-ADTRegistryKey -Key $RegPath -Name 'Installed by' -Value $($adtSession.InstalledBy) -Type String
    Set-ADTRegistryKey -Key $RegPath -Name 'Installed Date and Time' -Value $(Get-Date -Format "dd/MM/yyyy HH:mm") -Type String
    Set-ADTRegistryKey -Key $RegPath -Name 'MSTDescriptor' -Value $($adtSession.MSTDescriptor) -Type String
    Set-ADTRegistryKey -Key $RegPath -Name 'OSArchitectureType' -Value $($adtSession.AuditappArch) -Type String
    Set-ADTRegistryKey -Key $RegPath -Name 'PackageName' -Value $($adtSession.PackageName) -Type String
    Set-ADTRegistryKey -Key $RegPath -Name 'ProductCode' -Value $($adtSession.ProductCode) -Type String
    Set-ADTRegistryKey -Key $RegPath -Name 'ProductVersion' -Value $($adtSession.appVersion) -Type String
    Set-ADTRegistryKey -Key $RegPath -Name 'ReleaseVersion' -Value $($adtSession.appRevision) -Type String
    Set-ADTRegistryKey -Key $RegPath -Name 'TransformVersion' -Value $($adtSession.TransformVersion) -Type String

    Write-ADTLogEntry -Message "Audit Keys Created : $RegPath" -Severity 1 -Source $($adtSession.InstallPhase)

    ## --- STAGE 9: Final bits ---
    Write-Host "Stage 9: Evaluating final installation result..." -ForegroundColor Cyan

    # Logic to handle the exit code captured from Stage 4 ($installExitCode)
    If ($null -eq $installExitCode) {
        Write-Host "Error: Installation exit code was not captured." -ForegroundColor Red
        Close-ADTSession -ExitCode 1
    }

    Switch ($installExitCode) {
        # NI Reboot Required codes (Including -1 Mapped Success)
        { $_ -eq -1 -or $_ -eq -125071 -or $_ -eq -125072 } {
            Write-Host "Result: Success (Mapped from code $installExitCode). Mapping to SCCM 3010." -ForegroundColor Yellow
            # Close-ADTSession ensures the blue window closes and passes 3010 to SCCM
            Close-ADTSession -ExitCode 3010
        }
        
        # Success code
        0 {
            Write-Host "Result: Success (No Reboot Required)." -ForegroundColor Green
            Close-ADTSession -ExitCode 0
        }
        
        # All other codes are treated as failures
        Default {
            Write-Host "Result: Installation failed with code $installExitCode." -ForegroundColor Red
            Close-ADTSession -ExitCode $installExitCode
        }
    }

   

    ##================================================
    ## MARK: Post-Install
    ##================================================
    $adtSession.InstallPhase = "Post-$($adtSession.DeploymentType)"

    ## <Perform Post-Installation tasks here>

    #** Create Audit Registry Keys
    # If App Arch is NOT pure 64bit set to WOW6432Node
       If ($adtSession.AuditappArch -ne 'x64'){$RegPath = 'HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Audit\Software\'+$($adtSession.PackageName)}
	   Else{$RegPath = 'HKEY_LOCAL_MACHINE\SOFTWARE\Audit\Software\'+$($adtSession.PackageName)}

       Set-ADTRegistryKey -Key $RegPath -Name 'Application Name' -Value $($adtSession.AppName) -Type String
	   Set-ADTRegistryKey -Key $RegPath -Name 'Applied Patch' -Value $($adtSession.appPatch) -Type String
	   Set-ADTRegistryKey -Key $RegPath -Name 'Applied Transforms' -Value $($adtSession.appTransform) -Type String
	   Set-ADTRegistryKey -Key $RegPath -Name 'Installed by' -Value $($adtSession.InstalledBy) -Type String
	   Set-ADTRegistryKey -Key $RegPath -Name 'Installed Date and Time' -Value $(Get-Date -Format "dd/MM/yyyy hh:mm") -Type String
	   Set-ADTRegistryKey -Key $RegPath -Name 'MSTDescriptor' -Value $($adtSession.MSTDescriptor) -Type String
	   Set-ADTRegistryKey -Key $RegPath -Name 'OSArchitectureType' -Value $($adtSession.AuditappArch) -Type String
	   Set-ADTRegistryKey -Key $RegPath -Name 'PackageName' -Value $($adtSession.PackageName) -Type String
	   Set-ADTRegistryKey -Key $RegPath -Name 'ProductCode' -Value $($adtSession.ProductCode) -Type String
	   Set-ADTRegistryKey -Key $RegPath -Name 'ProductVersion' -Value $($adtSession.appVersion) -Type String
	   Set-ADTRegistryKey -Key $RegPath -Name 'ReleaseVersion' -Value $($adtSession.appRevision) -Type String
	   Set-ADTRegistryKey -Key $RegPath -Name 'TransformVersion' -Value $($adtSession.TransformVersion) -Type String

       Write-ADTLogEntry -Message "Audit Keys Created : $RegPath"  -Severity 1 -Source $($adtSession.InstallPhase)

       #** Force SCCM to request restart when used with the  -AllowRebootPassThru command line  
       #** $ExitCode = 1641


    ## Display a message at the end of the install.
    if (!$adtSession.UseDefaultMsi)
    {
        #** Show-ADTInstallationPrompt -Message 'You can customize text to appear at the end of an install or remove it completely for unattended installations.' -ButtonRightText 'OK' -Icon Information -NoWait
        # Show-ADTInstallationPrompt -Message "Uninstallation of $($adtSession.AppName) is complete" -ButtonRightText 'OK' -Icon Information -NoWait
    }
}

function Uninstall-ADTDeployment
{
    ##================================================
    ## MARK: Pre-Uninstall
    ##================================================
    $adtSession.InstallPhase = "Pre-$($adtSession.DeploymentType)"

    ## Show Welcome Message, close Internet Explorer with a 60 second countdown before automatically closing.
    #** Show-ADTInstallationWelcome -CloseProcesses iexplore -CloseProcessesCountdown 60

    ## Show Progress Message (with the default message).
    Show-ADTInstallationProgress  -StatusMessage "Uninstallation of $($adtSession.AppName) in progress. Please wait..."

    ## <Perform Pre-Uninstallation tasks here>


    ##================================================
    ## MARK: Uninstall
    ##================================================
    $adtSession.InstallPhase = $adtSession.DeploymentType

    ## Handle Zero-Config MSI uninstallations.
    if ($adtSession.UseDefaultMsi)
    {
        $ExecuteDefaultMSISplat = @{ Action = $adtSession.DeploymentType; FilePath = $adtSession.DefaultMsiFile }
        if ($adtSession.DefaultMstFile)
        {
            $ExecuteDefaultMSISplat.Add('Transform', $adtSession.DefaultMstFile)
        }
        Start-ADTMsiProcess @ExecuteDefaultMSISplat
    }

    ## <Perform Uninstallation tasks here>

    #** ========================================================
    #** MODIFY THIS SECTION WITH YOUR REQUIRED UNINSTALL STEPS
    #** ========================================================

    #** ----------------------------------
    #**  Useful built in variables
    #**  $envProgramFiles           ~ 64bit Program Files
    #**  $envProgramFilesX86        ~ 32bit Program Files
    #**  $envProgramData            ~ ProgramData Folder
    #**  $envSystemDrive            ~ System Drive e.g. C:
    #**  $envWinDir                 ~ Windows Folder
    #** ----------------------------------

    
    ##===========================================================================
    ## UNINSTALLATION SYNOPSIS:
    ## Stage 1: NI Core Removal - Targets LabVIEW 2025 Core packages; triggers 
    ##          dependency removal of 69+ sub-modules/toolkits.
    ## Stage 2: Registry Scrub - Purges 'ghost' entries (JKI Dragon, NI Software,
    ##          VIPM) from Windows Apps & Features registration.
    ## Stage 3: Directory Cleanup - Deletes specific ProgramData Start Menu 
    ##          folders and main Installation directories.
    ## Stage 4: Shortcut Remoal - Deletes .lnk files for JKI Dragon, 
    ##          NI MAX, VIPM, and Error Reporting Startup links!!
    ## Stage 5: Registry Cleanup - Deletes registry keys for JKI 
    ##          and National Instruments to wipe settings.
    ##===========================================================================

    $adtSession.InstallPhase = $adtSession.DeploymentType
    $nipkg = "C:\Program Files\National Instruments\NI Package Manager\nipkg.exe"

    ## STAGE 1: TRIGGER NI PACKAGE MANAGER REMOVAL
    If (Test-Path $nipkg) {
        Write-Host "Stage 1: Removing LabVIEW 2025 Core and all dependencies..." -ForegroundColor Cyan
        # Target the core packages to trigger a full wipe!
        & "$nipkg" remove ni-labview-2025-core-en ni-labview-2025-coreother --allow-uninstall --yes
        
        $uninstallExitCode = $LASTEXITCODE
        Write-Host "NI Package Manager execution finished with exit code: $uninstallExitCode" -ForegroundColor Yellow
    }

    ## STAGE 2: REMOVE REGISTRY ENTRIES (JKI DRAGON & NI SOFTWARE)
    Write-Host "Stage 2: Scrubbing Registry for remaining management entries..." -ForegroundColor Cyan
    $TargetApps = @("*JKI Dragon*", "NI Software", "NI Package Manager", "*VIPM*")
    $RegPaths = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall", 
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
    )

    foreach ($Path in $RegPaths) {
        if (Test-Path $Path) {
            Get-ChildItem -Path $Path | Where-Object { 
                $name = $_.GetValue("DisplayName")
                foreach ($app in $TargetApps) { if ($name -like $app) { return $true } }
                return $false
            } | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
        }
    }

    ## STAGE 3: REMOVE FOLDERS!
    Write-Host "Stage 3: Cleaning up Start Menu and Installation Folders..." -ForegroundColor Cyan
    $TargetFolders = @(
        "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\JKI",
        "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\National Instruments",
        "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\MGI Solution Explorer",
        "C:\ProgramData\National Instruments",
        "C:\ProgramData\JKI",
        "C:\Program Files\JKI",
        "C:\Program Files\National Instruments",
        "C:\Program Files\NI"
    )

    foreach ($Folder in $TargetFolders) {
        if (Test-Path $Folder) {
            Remove-Item -Path $Folder -Recurse -Force -ErrorAction SilentlyContinue
            Write-Host "Removed folder: $Folder" -ForegroundColor Gray
        }
    }

    ## STAGE 4: REMOVE SHORTCUTS
    Write-Host "Stage 4: Cleaning up Start Menu Shortcuts..." -ForegroundColor Cyan
    $TargetShortcuts = @(
        "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\JKI Dragon.lnk",
        "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\NI MAX.lnk",
        "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\VI Package Manager (VIPM).lnk",
        "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup\NI Error Reporting.lnk"
    )

    foreach ($Shortcut in $TargetShortcuts) {
        if (Test-Path $Shortcut) {
            Remove-Item -Path $Shortcut -Force -ErrorAction SilentlyContinue
            Write-Host "Removed shortcut: $Shortcut" -ForegroundColor Gray
        }
    }

    ## STAGE 5:REGISTRY CLEANUP
    Write-Host "Stage 5: Removing Core Software Registry Keys..." -ForegroundColor Cyan
    $ConfigKeys = @(
        "HKLM:\SOFTWARE\JKI",
        "HKLM:\SOFTWARE\National Instruments",
        "HKLM:\SOFTWARE\WOW6432Node\National Instruments"
    )

    foreach ($Key in $ConfigKeys) {
        if (Test-Path $Key) {
            Remove-Item -Path $Key -Recurse -Force -ErrorAction SilentlyContinue
            Write-Host "Removed Registry Key: $Key" -ForegroundColor Gray
        }
    }
    
            
    ##================================================
    ## MARK: Post-Uninstallation
    ##================================================
    $adtSession.InstallPhase = "Post-$($adtSession.DeploymentType)"

    ## <Perform Post-Uninstallation tasks here>

    #** Remove Audit Registry Keys
    # If $AuditappArch is NOT pure 64bit set to WOW6432Node
    If ($adtSession.AuditappArch -ne 'x64'){$RegPath = 'HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Audit\Software\'+$($adtSession.PackageName)}
    Else{$RegPath = 'HKEY_LOCAL_MACHINE\SOFTWARE\Audit\Software\'+$($adtSession.PackageName)}
    Remove-ADTRegistryKey -Key $RegPath
    Write-ADTLogEntry -Message "Audit Keys Removed : $RegPath"  -Severity 1 -Source $($adtSession.InstallPhase)

    #** Show-ADTInstallationPrompt -Message 'You can customize text to appear at the end of an install or remove it completely for unattended installations.' -ButtonRightText 'OK' -Icon Information -NoWait
    #Show-ADTInstallationPrompt -Message "The uninstallation of $($adtSession.AppName) is successful." -ButtonRightText 'OK' -Icon Information -NoWait
}

function Repair-ADTDeployment
{
    ##================================================
    ## MARK: Pre-Repair
    ##================================================
    $adtSession.InstallPhase = "Pre-$($adtSession.DeploymentType)"

    ## Show Welcome Message, close Internet Explorer with a 60 second countdown before automatically closing.
    Show-ADTInstallationWelcome -CloseProcesses iexplore -CloseProcessesCountdown 60

    ## Show Progress Message (with the default message).
    Show-ADTInstallationProgress

    ## <Perform Pre-Repair tasks here>


    ##================================================
    ## MARK: Repair
    ##================================================
    $adtSession.InstallPhase = $adtSession.DeploymentType

    ## Handle Zero-Config MSI repairs.
    if ($adtSession.UseDefaultMsi)
    {
        $ExecuteDefaultMSISplat = @{ Action = $adtSession.DeploymentType; FilePath = $adtSession.DefaultMsiFile }
        if ($adtSession.DefaultMstFile)
        {
            $ExecuteDefaultMSISplat.Add('Transform', $adtSession.DefaultMstFile)
        }
        Start-ADTMsiProcess @ExecuteDefaultMSISplat
    }

    ## <Perform Repair tasks here>


    ##================================================
    ## MARK: Post-Repair
    ##================================================
    $adtSession.InstallPhase = "Post-$($adtSession.DeploymentType)"

    ## <Perform Post-Repair tasks here>
}


##================================================
## MARK: Initialization
##================================================

# Set strict error handling across entire operation.
$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop
$ProgressPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
Set-StrictMode -Version 1

# Import the module and instantiate a new session.
try
{
    $moduleName = if ([System.IO.File]::Exists("$PSScriptRoot\PSAppDeployToolkit\PSAppDeployToolkit.psd1"))
    {
        Get-ChildItem -LiteralPath $PSScriptRoot\PSAppDeployToolkit -Recurse -File | Unblock-File -ErrorAction Ignore
        "$PSScriptRoot\PSAppDeployToolkit\PSAppDeployToolkit.psd1"
    }
    else
    {
        'PSAppDeployToolkit'
    }
    Import-Module -FullyQualifiedName @{ ModuleName = $moduleName; Guid = '8c3c366b-8606-4576-9f2d-4051144f7ca2'; ModuleVersion = '4.0.6' } -Force
    try
    {
        $iadtParams = Get-ADTBoundParametersAndDefaultValues -Invocation $MyInvocation
        $adtSession = Open-ADTSession -SessionState $ExecutionContext.SessionState @adtSession @iadtParams -PassThru
    }
    catch
    {
        Remove-Module -Name PSAppDeployToolkit* -Force
        throw
    }
}
catch
{
    $Host.UI.WriteErrorLine((Out-String -InputObject $_ -Width ([System.Int32]::MaxValue)))
    exit 60008
}


##================================================
## MARK: Invocation
##================================================

try
{
    Get-Item -Path $PSScriptRoot\PSAppDeployToolkit.* | & {
        process
        {
            Get-ChildItem -LiteralPath $_.FullName -Recurse -File | Unblock-File -ErrorAction Ignore
            Import-Module -Name $_.FullName -Force
        }
    }
    & "$($adtSession.DeploymentType)-ADTDeployment"
    Close-ADTSession
}
catch
{
    Write-ADTLogEntry -Message ($mainErrorMessage = Resolve-ADTErrorRecord -ErrorRecord $_) -Severity 3
    Show-ADTDialogBox -Text $mainErrorMessage -Icon Stop | Out-Null
    Close-ADTSession -ExitCode 60001
}
finally
{
    Remove-Module -Name PSAppDeployToolkit* -Force
}

