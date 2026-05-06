
# LabVIEW 2025 Q3 (WIM-Based) 📦

This script automates the installation and removal of **LabVIEW 2025** using a **WIM-mount strategy** to minimize the local disk footprint during staging. By mounting binaries directly from an image, it avoids the need to extract thousands of small files to the local drive.

> [!IMPORTANT]
> **Pre-requisite:** You must create a `.wim` file containing the install binaries extracted from the LabVIEW ISO before running this script.

---

### ✨ Key Features

*   **Modern PSADT Engine:** Fully compatible with the latest PSAppDeployToolkit v4.x framework utilizing the `Invoke-Application` logic.
*   **Full Lifecycle Support:** Includes dedicated logic for both **Silent Installation** and **Clean Uninstallation**.
*   **Stale Mount Cleanup:** Automatically detects and purges interrupted DISM sessions to prevent "Folder in use" errors during install or removal.
*   **NI Package Manager Integration:** Handles core engine installation, local feed registration, and product removal seamlessly.
*   **Exit Code Mapping:** Translates NI-specific return codes to standard **SCCM/Intune 3010** (Reboot Required) codes.
*   **Post-Install/Uninstall Cleanup:** Automatically removes desktop "junk" shortcuts and purges temporary mount directories.

---

### 🚀 Usage Instructions

1.  **Prepare Media:** Place your LabVIEW `.wim` file in the `Files` directory.
2.  **Script Configuration:** Rename the source script to **`Invoke-AppDeployToolkit.ps1`** to function with the modern PSADT v4.x engine.
3.  **Run via CLI:** Open PowerShell as Administrator and execute the desired action:

#### **To Install:**
```powershell
.\Invoke-AppDeployToolkit.ps1 "Install"
