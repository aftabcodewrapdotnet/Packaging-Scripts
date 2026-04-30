# Packaging Scripts
A collection of enterprise-grade application packaging scripts for use with PSAppDeployToolkit.

## LabVIEW 2025 Q3 (WIM-Based)
This script automates the installation of LabVIEW 2025 using a WIM-mount strategy to minimize local disk footprint during staging.

### Key Features:
* **Stale Mount Cleanup:** Automatically detects and purges interrupted DISM sessions.
* **NI Package Manager Integration:** Handles core engine installation and local feed registration.
* **Exit Code Mapping:** Translates NI-specific codes to standard SCCM/Intune 3010 (Reboot Required) codes.
* **Post-Install Cleanup:** Removes desktop "junk" shortcuts and purges temporary mount directories.
