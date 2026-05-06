# LabVIEW 2025 Q3 (WIM-Based) 📦

This script automates the installation of LabVIEW 2025 using a **WIM-mount strategy** to minimize the local disk footprint during staging. 

> **Note:** You will need to create a `.wim` file containing the install binaries extracted from the LabVIEW ISO before running this script.

### ✨ Key Features
*   **Stale Mount Cleanup:** Automatically detects and purges interrupted DISM sessions to prevent "Folder in use" errors.
*   **NI Package Manager Integration:** Handles core engine installation and local feed registration seamlessly.
*   **Exit Code Mapping:** Translates NI-specific codes to standard SCCM/Intune `3010` (Reboot Required) codes.
*   **Post-Install Cleanup:** Automatically removes desktop "junk" shortcuts and purges temporary mount directories.

### 🚀 Usage
1. Place your LabVIEW `.wim` in the `Files` directory.
2. Execute via the PSAppDeployToolkit:
   `Deploy-Application.ps1 -DeploymentType "Install" -DeployMode "Silent"`
