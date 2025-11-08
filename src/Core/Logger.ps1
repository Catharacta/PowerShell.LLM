# src/Core/Logger.ps1
# ==========================
# LLM Logging System
# ==========================

if (-not $global:LLMLogBuffer) { $global:LLMLogBuffer = @() }
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
    $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    $formatted = "[$timestamp][$Level] $Message"

    # ✅ 設定されたログレベル以上のもののみ記録
    if ($levels[$Level] -le $levels[$Script:LLMLogLevel]) {

        # グローバルバッファに追加（テストで参照される）
        $global:LLMLogBuffer += $formatted

        # Scriptスコープのキャッシュにも保存
        $Script:LLMLogCache += [PSCustomObject]@{
            Time    = $timestamp
            Level   = $Level
            Message = $Message
        }

        # コンソール出力
        Write-Host $formatted

        # ファイル書き込み
        try {
            $dir = Split-Path $Script:LLMLogFile -Parent
            if (-not (Test-Path $dir)) {
                New-Item -ItemType Directory -Force -Path $dir | Out-Null
            }
            Add-Content -Path $Script:LLMLogFile -Value $formatted
        }
        catch {
            Write-Host "⚠️ ログファイル書き込みに失敗しました: $($_.Exception.Message)"
        }
    }
}


function Get-LLMLogHistory {
    param(
        [ValidateSet("ERROR", "WARN", "INFO", "DEBUG", "ALL")]
        [string]$Level = "ALL",
        [switch]$AsJson,
        [int]$Last = 0
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
    $global:LLMLogBuffer = @()
    Write-Host "🧹 LLMログキャッシュをクリアしました。"
}

function Flush-LLMLogs {
    param(
        [string]$Path = "$PSScriptRoot/../Data/cache/session.log"
    )

    try {
        if (-not (Test-Path (Split-Path $Path))) {
            New-Item -ItemType Directory -Force -Path (Split-Path $Path) | Out-Null
        }

        if ($Script:LLMLogCache -and $Script:LLMLogCache.Count -gt 0) {
            $Script:LLMLogCache | ForEach-Object {
                $line = "[{0}][{1}] {2}" -f $_.Time, $_.Level, $_.Message
                Add-Content -Path $Path -Value $line
            }
            Write-LLMLog "Session logs flushed to $Path" "DEBUG"
        }
        else {
            Write-LLMLog "No logs to flush." "DEBUG"
        }
    }
    catch {
        Write-Warning "Failed to flush LLM logs: $_"
    }
}
