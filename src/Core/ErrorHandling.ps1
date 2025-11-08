# ===============================================
# ErrorHandling.ps1 - 共通エラーハンドリングユーティリティ
# ===============================================

function Handle-LLMError {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Message,

        [string]$Code = "LLMError",

        [string]$Context = "General",

        [System.Exception]$Exception
    )

    # 構造化エラーオブジェクトを作成
    $errorObject = [PSCustomObject]@{
        Status    = "Error"
        Type      = "LLMError"
        Message   = $Message
        Code      = $Code
        Context   = $Context
        Exception = $Exception
        Timestamp = (Get-Date)
    }

    # ログ出力
    if (Get-Command Write-LLMLog -ErrorAction SilentlyContinue) {
        Write-LLMLog -Level "ERROR" -Message "[$Context] $Message"
    }

    # ユーザー向けエラーメッセージ（カラー付き）
    Write-Host "❌ エラー: $Message" -ForegroundColor Red

    # 詳細ログ（DEBUG時）
    if ($Global:LLM_LogLevel -eq "DEBUG" -and $Exception) {
        Write-LLMLog -Level "DEBUG" -Message ("StackTrace: " + $Exception.StackTrace)
    }

    return $errorObject
}
