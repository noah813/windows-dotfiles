# Windows Dotfiles

This repository contains configuration files and scripts for setting up and managing a Windows environment. It includes tools and configurations that make it easier to work with various system settings and services on Windows.

## How to Use the Script

To use the provided PowerShell scripts, follow these steps:

### 1. Change PowerShell Execution Policy

Before running any scripts, ensure that your PowerShell execution policy is set to allow the execution of local scripts. To do this, run the following command in an elevated PowerShell window (run as Administrator):

```powershell
Set-ExecutionPolicy -Scope LocalMachine -ExecutionPolicy RemoteSigned
```

This sets the execution policy to `RemoteSigned`, which allows the execution of local scripts and requires remote scripts to be signed by a trusted publisher.

### 2. Running the Script

After setting the execution policy, you can run the scripts provided in this repository. To execute a script, simply open a PowerShell window and navigate to the directory where the script is located. Then run:

```powershell
.\script_name.ps1
```

Replace `script_name.ps1` with the actual script file you want to execute.
