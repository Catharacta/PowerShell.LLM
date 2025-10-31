# ===============================================
# ErrorHandling.ps1 - 共通エラーハンドリングユーティリティ
# ===============================================

if (-not (Get-Command Write-LLMLog -ErrorAction SilentlyContinue)) {
    . "$PSScriptRoot/Logger.ps1"
}

function Handle-LLMError {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [System.Management.Automation.ErrorRecord]$ErrorRecord,

        [string]$Context = "General"
    )

    $msg = $ErrorRecord.Exception.Message
    $type = $ErrorRecord.CategoryInfo.Category

    Write-LLMLog -Level "ERROR" -Message "[$Context] $type - $msg"

    # 詳細ログ（DEBUGのみ）
    if ($Global:LLM_LogLevel -eq "DEBUG") {
        Write-LLMLog -Level "DEBUG" -Message ("StackTrace: " + $ErrorRecord.ScriptStackTrace)
    }

    # ユーザー向けに見やすいメッセージを表示
    Write-Host "`n❌ エラー発生: $msg" -ForegroundColor Red

    # 必要に応じて再スロー（Pesterなどで失敗検出）
    if ($env:LLM_THROW_ON_ERROR -eq "1") {
        throw $ErrorRecord
    }
}
