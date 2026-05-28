# Digital Signature Utility 🖋️

 PowerShell utility designed to simplify the code-signing process for MSI and EXE installers. This script wraps Microsoft's `signtool.exe` with a GUI for file selection and handles SHA256/RFC 3161 timestamping logic automatically.

## ✨ Features
* **Dual File Pickers:** Easily select both the target installer and the PFX certificate through file picker
* **Secure Password Handling:** Captures certificate passwords securely via the command line
* **SHA256 Compliance:** Applies  SHA256 hashing for both the file signature and the timestamp.
* **Timestamping:** Uses the DigiCert RFC 3161 server to ensure the signature remains valid even after the certificate expires.
* **Output :** Automatically stages verified signed binaries to `C:\Signed Installer`.

## 📋 Prerequisites
* **Permissions:** Run as **Administrator**.
* **SignTool Path:** This script requires `signtool.exe` and its associated binaries to be located at `C:\SignTool\`.
* **Certificate:** Requires a valid `*.pfx` code-signing certificate and its password.

## 🛠️ How to get SignTool.exe
`signtool.exe` is part of the official **Windows SDK**. To set up the `C:\SignTool` directory:
1.  Download the **Windows SDK** from the [official Microsoft Download page](https://developer.microsoft.com/en-us/windows/downloads/windows-sdk/).
2.  During installation,  select **"Windows SDK Signing Tools for Desktop Apps"**.
3.  Once installed, locate `signtool.exe` (normally in `C:\Program Files (x86)\Windows Kits\10\bin\<version>\x64\`) and copy it (along with its supporting .dll files) to your `C:\SignTool` folder.

## 🚀 Usage Instructions
1.  Run **`Sign.ps1`** as Administrator.
2.  **Step 1:** Select the MSI or EXE you want to sign.
3.  **Step 2:** Select your PFX certificate.
4.  **Step 3:** Enter the PFX password when prompted.
5.  Retrieve your signed installer from **`C:\Signed Installer`**.

Note: Not currently tested on MSIX installer but should work!

---
*Developed by Aftab Khan | May 2026*
