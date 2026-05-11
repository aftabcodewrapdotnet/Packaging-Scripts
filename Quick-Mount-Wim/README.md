# Quick-Mount Utility 📂

A lightweight PowerShell productivity tool designed to bypass the manual CLI overhead of mounting Windows Image (.wim) files. 

## ✨ Key Features
* **GUI File Picker:** Integrated `System.Windows.Forms` allows users to browse for `.wim` files instead of manually typing long absolute paths.
* **Automated Workspace:** Intelligent logic checks for and creates the standard `C:\MountPath` directory automatically if it is missing.
* **Instant Access:** Upon a successful mount, the script automatically triggers `explorer.exe` to open the mount location for immediate verification.
* **Visual Status Tracking:** Provides color-coded console feedback to track the mounting process and confirm completion.

## 📋 Prerequisites
* **Permissions:** Must be executed with **Administrator** privileges (required for `Mount-WindowsImage`).
* **OS:** Windows 10 / 11 / Server.
* **Dependency:** Built on the native **DISM** (Deployment Image Servicing and Management) PowerShell module.

## 🚀 Usage Instructions
1.  Launch **PowerShell** as **Administrator**.
2.  Navigate to the directory and execute the utility:
    ```powershell
    .\Quick-Mount.ps1
    ```
3.  When the file dialog appears, navigate to and select your target `.wim` file.
4.  Wait for the "Mounting Complete!" message.
5.  The mount directory (`C:\MountPath`) will open automatically in a new File Explorer window.

---
*Developed by Aftab Khan | March 2026*
