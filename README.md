# Packaging-Scripts 🛠️

A collection of enterprise-grade automation scripts and deployment wrappers designed for Application Packaging and Endpoint Management (SCCM/Intune).

## 📂 Featured Tools

### 📦 [LabVIEW-2025](./LabVIEW-2025/)
PSAppDeployToolkit wrapper.
*   **Key Tech:** WIM-mounting strategy, DISM cleanup, and custom exit-code mapping.
*   **Purpose:** Optimises large-scale National Instruments LabVIEW deployments by minimizing disk footprint.

### 🖼️ [Build-Wim](./Build-Wim/)
A utility for rapid image creation.
*   **Key Tech:** PowerShell & DISM API.
*   **Purpose:** Quickly captures source directories into `.wim` files to support WIM-based application staging.

---

## 🛠️ Global Requirements
*   **OS:** Windows 10 / 11
*   **Shell:** PowerShell 5.1+
*   **Permissions:** Local Administrator (required for DISM and System-level installs)

## 🤝 Contribution & Usage
These scripts are part of my professional packaging portfolio. Feel free to explore the code. For specific installation instructions, please refer to the `README.md` within each tool's directory.


### 📂 [Quick-Mount-Wim](./Quick-Mount-Wim/)

A GUI-based utility for rapid WIM inspection.

* **Key Tech:** Windows Forms Integration & Mount-WindowsImage.
* **Purpose:** Provides a file picker to quickly mount WIMs to `C:\MountPath` for manual verification before deployment.
