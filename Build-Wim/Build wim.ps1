# Auto-WIM Capture Tool 🛠️

A streamlined PowerShell utility designed for **Application Packagers** to quickly capture source directories into Windows Image (.wim) files. 

Creating multiple WIMs manually during the packaging and sequencing process is time-consuming. This script automates the DISM capture process with built-in error handling and automatic directory management.

## 🚀 Features
*   **Auto-Directory Creation:** Automatically creates `C:\Wim` if it doesn't already exist.
*   **Admin Verification:** Checks for Elevated/Administrator privileges before execution.
*   **Validation:** Verifies the source path exists before attempting the capture to save time.
*   **User-Friendly Prompts:** Simple CLI interface for source paths and output naming.

## 📋 Requirements
*   **OS:** Windows 10 / 11 / Server
*   **Privileges:** Must be run as **Administrator**.
*   **Module:** Requires the `DISM` PowerShell module (included by default in most Windows environments or via Windows ADK).

## 🛠️ Usage
1. Download `Capture-Wim.ps1`.
2. Right-click the file and select **Run with PowerShell** (ensure you are elevated).
3. Enter the **Source Path** (e.g., `C:\AppSources\MySoftware`).
4. Enter the **WIM Name** (e.g., `MySoftware_v1`).
5. The final image will be exported to `C:\Wim\<Name>.wim`.

## 📁 Paths & Logs
*   **Output Folder:** `C:\Wim`
*   **DISM Logs:** `C:\Windows\Logs\DISM\dism.log`

---
*Developed to speed up the packaging workflow by [Your Name/GitHub Handle].*