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
# ENSURE THE SSHD SERVICE IS RUNNING
#======================================================================
try {
    $service = Get-Service -Name sshd -ErrorAction SilentlyContinue
    if ($service -and $service.Status -eq 'Running') {
        Write-Output "The sshd service is already running."
    } else {
        Start-Service sshd
        Write-Output "The sshd service has been started."
    }
    Set-Service -Name sshd -StartupType 'Automatic'
    Write-Output "The sshd service startup type has been set to automatic."
} catch {
    Write-Error "An error occurred while starting or configuring the sshd service: $_"
}

#======================================================================
# ENSURE THE SSH-AGENT SERVICE IS RUNNING
#======================================================================
try {
    $agentService = Get-Service -Name ssh-agent -ErrorAction SilentlyContinue
    if ($agentService) {
        if ($agentService.Status -eq 'Running') {
            Write-Output "The ssh-agent service is already running."
        } else {
            Start-Service ssh-agent
            Write-Output "The ssh-agent service has been started."
        }
        Set-Service -Name ssh-agent -StartupType Automatic
        Write-Output "The ssh-agent service startup type has been set to automatic."
    } else {
        Write-Error "The ssh-agent service is not installed or unavailable."
    }
} catch {
    Write-Error "An error occurred while configuring the ssh-agent service: $_"
}

#======================================================================
# ENSURE THE FIREWALL RULE EXISTS AND IS ENABLED
#======================================================================
try {
    $firewallRule = Get-NetFirewallRule -Name "OpenSSH-Server-In-TCP" -ErrorAction SilentlyContinue
    if ($firewallRule) {
        if ($firewallRule.Enabled -eq 'True') {
            Write-Output "The firewall rule 'OpenSSH-Server-In-TCP' already exists and is enabled."
        } else {
            Enable-NetFirewallRule -Name "OpenSSH-Server-In-TCP"
            Write-Output "The firewall rule 'OpenSSH-Server-In-TCP' exists but was disabled. It has now been enabled."
        }
    } else {
        Write-Output "The firewall rule 'OpenSSH-Server-In-TCP' does not exist. Creating it..."
        New-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
        Write-Output "The firewall rule 'OpenSSH-Server-In-TCP' has been created."
    }
} catch {
    Write-Error "An error occurred while configuring the firewall rule: $_"
}

#======================================================================
# DEFINE THE PATH WHERE THE SSH KEY SHOULD BE STORED
#======================================================================
$user = $env:USERNAME
ssh -o BatchMode=yes -o StrictHostKeyChecking=no "$user@localhost"
$keyPath = "$env:USERPROFILE\.ssh\id_ecdsa"
if (Test-Path $keyPath) {
    Write-Output "The ECDSA key already exists at $keyPath. Skipping key generation."
} else {
    Write-Output "The ECDSA key does not exist. Generating a new key..."
    ssh-keygen -t ecdsa -f $keyPath -N " "
    Write-Output "ECDSA key generated at $keyPath."
}
