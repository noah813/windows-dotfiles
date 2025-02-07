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

# 列出所有 WSL 發行版
wsl --list --all

# 讓使用者輸入要轉移的 WSL 發行版名稱（例如 "Ubuntu"）
$sourceDist = Read-Host "請輸入要轉移的 WSL 發行版名稱"

# 讓使用者輸入發行版儲存位置（例如 C:\Users\YourUsername）
$targetDir = Read-Host "請輸入儲存路徑 (例如 C:\Users\YourUsername)"

# 將指定的 WSL 發行版匯出成 tar 檔案
wsl --export $sourceDist "$targetDir\$sourceDist.tar"

# 刪除指定的 WSL 發行版
wsl --unregister $sourceDist

# 從 tar 檔案匯入 WSL 發行版，並指定新的資料夾為該發行版存放路徑
wsl --import $sourceDist "$targetDir\$sourceDist" "$targetDir\$sourceDist.tar"

# 取得當前使用者名稱
$user_name = $env:USERNAME
$configPath = "$env:USERPROFILE\.wslconfig"

if (-not (Test-Path $configPath)) {
    @"
[wsl2]
user=$user_name
"@ | Out-File -FilePath $configPath -Encoding ascii
    Write-Output ".wslconfig 不存在，已建立新檔，並設定用戶為 $user_name"
} else {
    # 讀取現有內容
    $configContent = Get-Content $configPath
    # 檢查是否有 [wsl2] 區塊
    if ($configContent -match '^\[wsl2\]') {
        # 如果存在，就檢查是否已有 user= 設定
        $foundUserSetting = $false
        foreach ($line in $configContent) {
            if ($line.Trim() -match '^user=') {
                if ($line.Trim() -eq "user=$user_name") {
                    $foundUserSetting = $true
                    break
                }
            }
        }
        if (-not $foundUserSetting) {
            # 插入 user= 設定 (這裡採用簡單附加的方式)
            Add-Content -Path $configPath -Value "user=$user_name"
            Write-Output "已在現有 [wsl2] 區塊中附加 user=$user_name"
        } else {
            Write-Output ".wslconfig 中已存在正確的 user 設定"
        }
    } else {
        # 如果不存在 [wsl2] 區塊，則附加完整區塊內容
        Add-Content -Path $configPath -Value ""
        Add-Content -Path $configPath -Value "[wsl2]"
        Add-Content -Path $configPath -Value "user=$user_name"
        Write-Output "已新增 [wsl2] 區塊與 user=$user_name 設定至現有 .wslconfig"
    }
}