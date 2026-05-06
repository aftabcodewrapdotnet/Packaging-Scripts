# PowerShell WIM Capture Utility 🛠️

General-purpose PowerShell script for capturing any source directory into a **Windows Image (.wim)** file. This utility is designed to streamline the software staging process in enterprise environments by converting large file structures into compressed, mountable containers.

## ✨ Key Features
*   **Universal Capture:** Optimised for any folder structure, including software source files, driver repositories, or OS components.
*   **Automatic Workspace Management:** Automatically detects and creates the `C:\Wim` output directory if it does not already exist.
*   **Built-in Safety Checks:** 
    *   **Admin Verification:** Ensures the session has elevated privileges required for DISM operations.
    *   **Path Validation:** Verifies the existence of the source directory before execution to prevent process failure.
*   **Interactive CLI:** Simple prompts for defining capture paths and file names.

## 📋 Prerequisites
*   **Operating System:** Windows 10, Windows 11, or Windows Server.
*   **Permissions:** Must be executed as **Administrator** (required for WIM capture).
*   **Dependencies:** Requires the **DISM** (Deployment Image Servicing and Management) PowerShell module. 
    *   *Note: This is included by default on most Windows installations. If running in a "WinPE" or specialized environment, the [Windows ADK](https://learn.microsoft.com/en-us/windows-hardware/get-started/adk-install) may be required.*

## 🚀 Common Use Cases
*   **Application Packaging:** Converting large installation sources into WIMs to minimize local disk footprint during staging (e.g., LabVIEW, MATLAB, Autodesk).
*   **Infrastructure Management:** Capturing file-based image components for OS deployment (OSD) workflows.
*   **Data Archiving:** Compressing complex directory structures into a single, mountable file format.

## 🛠️ Usage Instructions
1.  Open **PowerShell** as **Administrator**.
2.  Navigate to the script directory and execute the utility:
    ```powershell
    .\Build-Wim.ps1
    ```
3.  Input the **Full Path** of the folder you wish to capture when prompted by the CLI.
4.  Assign a **Name** for the resulting `.wim` file.
5.  The script will execute the DISM capture and save the final image to **`C:\Wim`**.

## 📁 Output & Logging
*   **Target Output:** `C:\Wim`
*   **System Logs:** `C:\Windows\Logs\DISM\dism.log`


---
*A professional automation utility for Application Packagers and System Administrators.*
