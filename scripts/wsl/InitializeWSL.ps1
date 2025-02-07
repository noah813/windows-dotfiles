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
# INSTALL WSL
#======================================================================

if (-not (Get-Command "wsl" -ErrorAction SilentlyContinue)) {
    Write-Output "WSL 未安裝，開始執行安裝..."
    wsl --install --distribution Ubuntu
   
    # 檢查是否安裝成功
    if (-not (Get-Command "wsl" -ErrorAction SilentlyContinue)) {
        Write-Output "WSL 安裝失敗。"
        Exit
    }

    # 詢問用戶是否重啟電腦
    $wslRestart = Read-Host "是否要重啟電腦？(Y/N)"
    if ($wslRestart -ieq "Y") {    
        shutdown /r /t 10
    }
} else {
    Write-Output "WSL 已安裝。"
}
