# Get all subfolders in the current directory
$subFolders = Get-ChildItem -Path . -Directory

foreach ($folder in $subFolders) {
    # Point to your PSADT entry point
    $scriptPath = Join-Path -Path $folder.FullName -ChildPath "Invoke-AppDeployToolkit.ps1"

    if (-not (Test-Path $scriptPath)) {
        Write-Host "Skipping '$($folder.Name)': Invoke-AppDeployToolkit.ps1 not found."
        continue
    }

    Write-Host "--- Validating Standards for: $($folder.Name) ---"
    $content = Get-Content -Path $scriptPath -Raw

    # Extract values from the ADT session hash table
    $packageName = if ($content -match "PackageName\s*=\s*'([^']+)'") { $matches[1] } else { $null }
    $appArch = if ($content -match "AppArch\s*=\s*'([^']+)'") { $matches[1] } else { $null }

    # Validation Rules
    $isValid = $true

    if ($appArch -eq 'x64' -and $packageName -notmatch "_x64_P1$") {
        Write-Error "Naming Violation: '$packageName' (in $($folder.Name)) is x64 but missing '_x64_P1' suffix."
        $isValid = $false
    }
    elseif ($appArch -eq 'x86' -and $packageName -match "_x64_P1") {
        Write-Error "Naming Violation: '$packageName' (in $($folder.Name)) is x86 but contains 64-bit suffix."
        $isValid = $false
    }

    if ($isValid) {
        Write-Host "Validation passed for: $packageName"
    }
}
