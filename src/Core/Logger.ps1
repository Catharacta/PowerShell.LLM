# src/Core/Logger.ps1
# ログレベル: ERROR < WARN < INFO < DEBUG

if (-not (Get-Variable -Name LLMLogCache -Scope Script -ErrorAction SilentlyContinue)) {
    $Script:LLMLogCache = @()
}

$Script:LLMLogLevel = "INFO"
$Script:LLMLogFile  = Join-Path $PSScriptRoot "../Data/cache/session.log"

function Set-LLMLogLevel {
    param(
        [ValidateSet("ERROR", "WARN", "INFO", "DEBUG")]
        [string]$Level
    )
    $Script:LLMLogLevel = $Level
}

function Write-LLMLog {
    param(
        [Parameter(Mandatory)] [string]$Message,
        [ValidateSet("ERROR", "WARN", "INFO", "DEBUG")] [string]$Level = "INFO"
    )

    $levels = @{ "ERROR" = 1; "WARN" = 2; "INFO" = 3; "DEBUG" = 4 }
    if ($levels[$Level] -gt $levels[$Script:LLMLogLevel]) { return }

    $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    $formatted = "[$timestamp][$Level] $Message"

    # 出力とキャッシュ
    Write-Host $formatted
    $Script:LLMLogCache += [PSCustomObject]@{
        Time  = $timestamp
        Level = $Level
        Message = $Message
    }

    # ログファイルにも追記
    try {
        $dir = Split-Path $Script:LLMLogFile -Parent
        if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
        Add-Content -Path $Script:LLMLogFile -Value $formatted
    } catch {
        Write-Host "⚠️ ログファイル書き込みに失敗しました: $($_.Exception.Message)"
    }
}

function Get-LLMLogHistory {
    param(
        [ValidateSet("ERROR", "WARN", "INFO", "DEBUG", "ALL")]
        [string]$Level = "ALL",
        [switch]$AsJson,
        [int]$Last = 0  # 直近N件のみ表示
    )

    $logs = $Script:LLMLogCache

    if ($Level -ne "ALL") {
        $logs = $logs | Where-Object { $_.Level -eq $Level }
    }

    if ($Last -gt 0) {
        $logs = $logs | Select-Object -Last $Last
    }

    if ($AsJson) {
        return ($logs | ConvertTo-Json -Depth 5)
    }

    return $logs | Format-Table -AutoSize
}

function Clear-LLMLogCache {
    $Script:LLMLogCache = @()
    Write-Host "🧹 LLMログキャッシュをクリアしました。"
}
