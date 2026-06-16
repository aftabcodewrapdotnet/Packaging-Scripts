# Packaging-Scripts 🛠️

A collection of enterprise-grade automation scripts and deployment wrappers designed for Application Packaging and Endpoint Management (SCCM/Intune).

## 📂 Featured Tools

### 🛠️ [Create Packaging VM](./Create%20Packaging%20VM)

An automated environment-provisioning script for creating clean virtual machines for application packaging 

* **Key Tech:** PowerShell, Winget API, Registry Manipulation, and Sysinternals Integration.
* **Purpose:** Cleans a baseline machine, deploys essential packaging tools and configures custom `NT AUTHORITY\SYSTEM` shortcuts to streamline application packaging

### 📦 [LabVIEW 2025](./LabVIEW%202025/)
PSAppDeployToolkit wrapper.
*   **Key Tech:** WIM-mounting strategy, DISM cleanup, and custom exit-code mapping.
*   **Purpose:** Optimises large-scale National Instruments LabVIEW deployments by minimizing disk footprint.

### 🖼️ [Build-Wim](./Build-Wim/)
A utility for rapid image creation.
*   **Key Tech:** PowerShell & DISM API.
*   **Purpose:** Quickly captures source directories into `.wim` files to support WIM-based application staging.


### 📂 [Quick-Mount-Wim](./Quick-Mount-Wim/)

A GUI-based utility for rapid WIM inspection.

* **Key Tech:** Windows Forms Integration & Mount-WindowsImage.
* **Purpose:** Provides a file picker to quickly mount WIMs to `C:\MountPath` for manual verification before deployment.


### 🚀 [MSIX-to-CIM](./MSIX-to-CIM/)

Automated conversion for AVD App Attach

* **Key Tech:** CIMFS (Composite File System), MSIXMGR API, and GUI integration.
* **Purpose:** Streamlines the creation of .cim images from MSIX packages for AVD

### 🖋️ [Code-Sign-Utility](./Code-Sign-Utility/)
SHA256 code-signing for MSI and EXE installers

* **Key Tech:** Microsoft SignTool, SHA256/RFC 3161 compliance, and WinForms UI.

* **Purpose:** Simplifies the signing process to ensure installers pass Windows SmartScreen, Intune validation, and enterprise security policies etc

## 🤝 Contribution & Usage
These scripts are part of my professional packaging portfolio. Feel free to explore the code. For specific installation instructions, please refer to the `README.md` within each tool's directory.



