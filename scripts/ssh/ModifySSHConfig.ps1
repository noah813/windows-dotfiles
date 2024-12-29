#======================================================================
# CHECK IF THE SCRIPT IS ELEVATED / ELEVATE IF NOT
#======================================================================
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    $arguments = "& '" + $myinvocation.mycommand.definition + "'"
    Start-Process powershell -Verb runAs -ArgumentList $arguments
    Exit
}

#======================================================================
# BYPASS EXECUTION POLICY TO ALLOW SCRIPT TO RUN
#======================================================================
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

#======================================================================
# MODIFY SSHD CONFIG
#======================================================================
$sshdConfig = "C:\ProgramData\ssh\sshd_config"
$backupConfig = "C:\ProgramData\ssh\sshd_config.bak"
if (Test-Path $backupConfig) {
    if (Test-Path $sshdConfig) {
        Remove-Item -Path $sshdConfig -Force
        Write-Output "Existing sshd_config file removed."
    }
    Move-Item -Path $backupConfig -Destination $sshdConfig -Force
    Write-Output "sshd_config has been restored by moving the backup."
} else {
    Write-Output "Backup file not found at $backupConfig. Cannot restore."
}
if (-Not (Test-Path $backupConfig)) {
    Copy-Item -Path $sshdConfig -Destination $backupConfig
    Write-Output "Backup created at $backupConfig"
} else {
    Write-Output "Backup already exists at $backupConfig"
}
if (Select-String -Pattern "^#PubkeyAuthentication yes" $sshdConfig) {
    (Get-Content $sshdConfig) | ForEach-Object { $_ -replace "^#PubkeyAuthentication yes", "PubkeyAuthentication yes" } | Set-Content $sshdConfig
    Write-Output "Uncommented PubkeyAuthentication yes"
} elseif (-Not (Select-String -Pattern "^PubkeyAuthentication yes" $sshdConfig)) {
    Add-Content -Path $sshdConfig -Value "PubkeyAuthentication yes"
    Write-Output "Added PubkeyAuthentication yes to sshd_config"
}
if (Select-String -Pattern "^#AuthorizedKeysFile .ssh/authorized_keys" $sshdConfig) {
    (Get-Content $sshdConfig) | ForEach-Object { $_ -replace "^#AuthorizedKeysFile	.ssh/authorized_keys", "AuthorizedKeysFile	.ssh/authorized_keys" } | Set-Content $sshdConfig
    Write-Output "Uncommented AuthorizedKeysFile .ssh/authorized_keys"
} elseif (-Not (Select-String -Pattern "^AuthorizedKeysFile	.ssh/authorized_keys" $sshdConfig)) {
    Add-Content -Path $sshdConfig -Value "AuthorizedKeysFile	.ssh/authorized_keys"
    Write-Output "Added AuthorizedKeysFile .ssh/authorized_keys to sshd_config"
}
if (Select-String -Pattern "^#PasswordAuthentication no" $sshdConfig) {
    (Get-Content $sshdConfig) | ForEach-Object { $_ -replace "^#PasswordAuthentication no", "PasswordAuthentication no" } | Set-Content $sshdConfig
    Write-Output "Uncommented PasswordAuthentication no"
} elseif (-Not (Select-String -Pattern "^PasswordAuthentication no" $sshdConfig)) {
    Add-Content -Path $sshdConfig -Value "PasswordAuthentication no"
    Write-Output "Added PasswordAuthentication no to sshd_config"
}
if (Select-String -Pattern "^Match Group administrators" $sshdConfig) {
    (Get-Content $sshdConfig) | ForEach-Object { $_ -replace "^Match Group administrators", "#Match Group administrators" } | Set-Content $sshdConfig
    Write-Output "Commented out Match Group administrators"
}
if (Select-String -Pattern "AuthorizedKeysFile __PROGRAMDATA__/ssh/administrators_authorized_keys" $sshdConfig) {
    (Get-Content $sshdConfig) | ForEach-Object { $_ -replace "AuthorizedKeysFile __PROGRAMDATA__/ssh/administrators_authorized_keys", "#AuthorizedKeysFile __PROGRAMDATA__/ssh/administrators_authorized_keys" } | Set-Content $sshdConfig
    Write-Output "Commented out AuthorizedKeysFile __PROGRAMDATA__/ssh/administrators_authorized_keys"
} elseif (-Not (Select-String -Pattern "AuthorizedKeysFile __PROGRAMDATA__/ssh/administrators_authorized_keys" $sshdConfig)) {
    Add-Content -Path $sshdConfig -Value "#AuthorizedKeysFile __PROGRAMDATA__/ssh/administrators_authorized_keys"
    Write-Output "Added commented AuthorizedKeysFile __PROGRAMDATA__/ssh/administrators_authorized_keys to sshd_config"
}
$serviceName = "sshd"
if (Get-Service -Name $serviceName -ErrorAction SilentlyContinue) {
    Restart-Service -Name $serviceName -Force
    Write-Output "SSH service has been restarted."
} else {
    Write-Output "SSH service not found. Please ensure the OpenSSH server is installed and running."
}
Write-Output "sshd_config modifications complete."