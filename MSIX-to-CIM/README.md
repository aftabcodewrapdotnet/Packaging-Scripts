# MSIX to CIM Conversion Utility 

 Script designed for **AVD (Azure Virtual Desktop) App Attach**  This utility transforms standard MSIX/APPX packages into **.cim** (CIMFS) images

## ✨ Key Features
* **GUI Integration:** Browse and select MSIX/APPX packages using a native Windows File Explorer dialog.
* **CIMFS Optimisation:** Configured to use parameters (`-filetype CIM` and `-rootDirectory apps`) to ensure quick mounting
* **Dependency Monitoring:** Automatically scans and highlights package dependencies in **green** within the console
* **Permission Integrity:** Utilises the `-applyACLs` flag to preserve original NTFS file permissions within the final image.
* **Workspace Management:** Intelligent logic verifies and creates the `C:\cim` output environment if it does not already exist.

## 📋 Prerequisites
* **Permissions:** Must be executed with **Administrator** privileges.
* **Dependencies:** Requires `msixmgr.exe` to be located in `C:\msixmgr\`.
* **Signing:** The source MSIX package must be digitally signed (e.g., using a *.pfx) before conversion.

## 🚀 Usage Instructions
1.  Launch **PowerShell** as **Administrator**.
2.  Navigate to the folder and execute the script:
    ```powershell
    .\MSIX-to-CIM.ps1
    ```
3.  Select your target **.msix** package via the file picker.
4.  Input a name for your output image (extension handled automatically).
5.  Retrieve your *.cim from **`C:\cim`**.

---
*Developed by Aftab Khan | February 2026*
