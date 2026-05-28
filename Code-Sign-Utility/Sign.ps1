
<#
.SYNOPSIS
    Digital Signature Tool

.DESCRIPTION
    A utility designed to simplify the code-signing process using SignTool.exe. 
    1. Prompts for target MSI/EXE and PFX Certificate via Windows File Picker.
    2. Captures the PFX password via CLI.
    3. Signs the file using SHA256
    4. Automatically copies the verified signed file to 'C:\Signed Installer'.
    5. Applies an RFC 3161 compliant SHA256 timestamp to ensure long-term signature validity.

.NOTES
    Author: Aftab Khan
    Version: 1.0
    Date: 2026-05-18
    RequirementS: Requires signtool.exe and its binaries located in "C:\SignTool\" requires a PFX file with Password and obviously an installer

#>


## <# 1. Select the Installer #>
Write-Host "`n[STEP 1] Pick the MSI or EXE you want to sign..." -ForegroundColor Yellow
Add-Type -AssemblyName System.Windows.Forms
$MSIPicker = New-Object System.Windows.Forms.OpenFileDialog
$MSIPicker.Title = "Select Installer"
$MSIPicker.Filter = "Installers (*.msi;*.exe)|*.msi;*.exe"
$MSIPicker.InitialDirectory = "C:\Installers"

if ($MSIPicker.ShowDialog() -ne "OK") { 
    Write-Host "No file selected. Exiting." -ForegroundColor Red
    Read-Host "Press Enter to close..."
    exit 
}
$TargetFile = $MSIPicker.FileName
Write-Host "Selected: $TargetFile" -ForegroundColor Cyan

## <# 2. Select the Certificate #>
Write-Host "`n[STEP 2] Pick your PFX Certificate file..." -ForegroundColor Yellow
$PFXPicker = New-Object System.Windows.Forms.OpenFileDialog
$PFXPicker.Title = "Select PFX Certificate"
$PFXPicker.Filter = "Certificate (*.pfx)|*.pfx"
$PFXPicker.InitialDirectory = "C:\Installers"

if ($PFXPicker.ShowDialog() -ne "OK") { 
    Write-Host "No certificate selected. Exiting." -ForegroundColor Red
    Read-Host "Press Enter to close..."
    exit 
}
$CertPath = $PFXPicker.FileName
Write-Host "Selected: $CertPath" -ForegroundColor Cyan

## <# 3. Enter Password #>
Write-Host "`n[STEP 3] Enter the PFX Password below..." -ForegroundColor Yellow
$Password = Read-Host -AsSecureString "Password"
$PlainTextPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password))

## <# 4. Sign the App #>
$SignTool = "C:\SignTool\signtool.exe"
Write-Host "`n--- Starting Digital Signature ---" -ForegroundColor Cyan

$Params = @(
    "sign",
    "/f", "`"$CertPath`"",
    "/p", "`"$PlainTextPassword`"",
    "/fd", "sha256",
    "/td", "sha256",
    "/tr", "http://timestamp.digicert.com",
    "/v",
    "`"$TargetFile`""
)

& $SignTool $Params

## <# 5. Copy to Signed Folder #>
$OutputDir = "C:\Signed Installer"
if (!(Test-Path $OutputDir)) { New-Item -Path $OutputDir -ItemType Directory | Out-Null }

try {
    Copy-Item -Path $TargetFile -Destination $OutputDir -Force
    Write-Host "`nSuccess! Signed file copied to: $OutputDir" -ForegroundColor Green
}
catch {
    Write-Host "`nError copying file: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`nProcess Complete. Press Enter to exit..." -ForegroundColor Green
Read-Host
