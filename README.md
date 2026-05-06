# Packaging-Scripts 🛠️

A collection of enterprise-grade automation scripts and deployment wrappers designed for Application Packaging and Endpoint Management (SCCM/Intune).

## 📂 Featured Tools

### 📦 [LabVIEW-2025](./LabVIEW-2025/)
A high-complexity PSAppDeployToolkit wrapper.
*   **Key Tech:** WIM-mounting strategy, DISM cleanup, and custom exit-code mapping.
*   **Purpose:** Optimizes large-scale National Instruments deployments by minimizing disk footprint.

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
