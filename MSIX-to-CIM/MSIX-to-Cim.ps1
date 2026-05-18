<#
.SYNOPSIS
 MSIX to CIM Conversion Utility for App Attach!

.DESCRIPTION
This script will automate the transformation of MSIX packages into a .cim image
When run, it should open file explorer so you can point it to your msix file

Note: The msix package should be signed using our Brunel.pfx    


    Key Features:
    - GUI interface for MSIX package selection.
    - Will check if C:\cim exists and creates if not exist 
    - MSIXMGR pathed to C:\msixmgr\msixmgr.exe
    - Dependency monitoring with alert at the end of cim creation 

.PARAMETERS USED
    -applyACLs      : Preserves MSIX file permissions within the CIM.
    -create         : Generates the new CIM image file.
    -filetype CIM   : Uses the high-performance CIMFS format.
    -rootDirectory  : Sets the internal mount point to 'apps'.

.NOTES
    Author: Aftab Khan
    Requires: Needs to be run as admin!
    Tools: msixmgr.exe must be located in C:\msixmgr\
    Date: 19/02/26
#>


# Windows Forms assembly for the GUI  --- allows you to point to your msix package using file explorer
Add-Type -AssemblyName System.Windows.Forms
$FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ 
    InitialDirectory = [Environment]::GetFolderPath('Desktop')
    Filter = "MSIX Files (*.msix;*.appx)|*.msix;*.appx|All Files (*.*)|*.*"
    Title = "Select your MSIX Package"
}

# 1. Open File Explorer
$null = $FileBrowser.ShowDialog()
$msixPath = $FileBrowser.FileName

if ([string]::IsNullOrWhiteSpace($msixPath)) {
    Write-Host "No file selected. Exiting script." -ForegroundColor Red
    return
}

# 2. CIM filename
$cimName = Read-Host "What would you like to call the .cim file? (Exclude extension)"

# 3.output directory - this is where the cim file will be dropped 
$outputPath = "C:\cim"
if (!(Test-Path $outputPath)) {
    New-Item -ItemType Directory -Path $outputPath | Out-Null
}

$destinationFile = Join-Path $outputPath "$cimName.cim"
$msixmgrPath = "C:\msixmgr\msixmgr.exe"

# 4. run msixmgr
$params = @(
    "-Unpack",
    "-packagePath", "$msixPath",
    "-destination", "$destinationFile",
    "-applyACLs",
    "-create",
    "-filetype", "CIM",
    "-rootDirectory", "apps"
)

Write-Host "`nProcessing: $(Split-Path $msixPath -Leaf)" -ForegroundColor Cyan
Write-Host "Creating CIM image: $cimName..." -ForegroundColor Cyan

# capture output
$processOutput = & $msixmgrPath @params 2>&1

# 5.highlight dependencies in Green
foreach ($line in $processOutput) {
    if ($line -like "*dependency*" -or $line -like "*dependencies*") {
        Write-Host $line -ForegroundColor Green
    } else {
        Write-Host $line
    }
}

# 6. Final bits and bobs!
if (Test-Path $destinationFile) {
    Write-Host "`ncim file copied to $outputPath" -ForegroundColor Yellow
    
} else {
    Write-Host "`nError: The CIM file was not found in $outputPath. Check the logs above." -ForegroundColor Red
}