
<#
.SYNOPSIS
    This will quickly mount a wim file!

.DESCRIPTION
   Will open file explorer so you can point it to the .wim file
   Mounts to C:\MountPath
   Opens C:\MountPath
    

.NOTES
    Author: Aftab Khan
    Date: March 2026
    Requires: Administrative Privileges and *.wim file
#>


# Ensure the Mount Path exists
$MountPath = "C:\MountPath"
if (!(Test-Path $MountPath)) {
    New-Item -ItemType Directory -Path $MountPath | Out-Null
    Write-Host "Created directory $MountPath" -ForegroundColor Cyan
}

# Load File explorer
Add-Type -AssemblyName System.Windows.Forms
$FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{
    InitialDirectory = [Environment]::GetFolderPath('Desktop')
    Filter = "WIM Files (*.wim)|*.wim"
    Title = "Select the WIM file you want to mount"
}

# Open 
if ($FileBrowser.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
    $WimPath = $FileBrowser.FileName
    Write-Host "Selected: $WimPath" -ForegroundColor Green
    
    Write-Host "Mounting WIM to $MountPath... This may take a moment." -ForegroundColor Yellow
    
    # Mount WIM
    Mount-WindowsImage -ImagePath $WimPath -Index 1 -Path $MountPath
    
    Write-Host "Mounting Complete!" -ForegroundColor Green
    explorer.exe $MountPath
}
else {
    Write-Host "Operation cancelled by user." -ForegroundColor Red
}

