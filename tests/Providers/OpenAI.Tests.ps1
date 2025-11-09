# tests/Providers/OpenAI.Tests.ps1
Import-Module "$PSScriptRoot/../../src/PowerShell.LLM.psd1" -Force

Describe "OpenAI Provider" {
    BeforeAll {
        # ✅ テスト環境のAPIキーを設定
        $env:LLM_API_KEY_OPENAI = "test-key"

        # ✅ ロガーが未初期化の場合に初期化
        if (-not (Get-Command Write-LLMLog -ErrorAction SilentlyContinue)) {
            . "$PSScriptRoot/../../src/Core/Logger.ps1"
        }

        if (-not $global:LLMLogBuffer) {
            $global:LLMLogBuffer = @()
        }
    }

    It "should have Invoke-OpenAI function" {
        Get-Command Invoke-OpenAI -ErrorAction SilentlyContinue | Should -Not -BeNullOrEmpty
    }

    It "should throw clear error if API key missing" {
        Remove-Item Env:\LLM_API_KEY_OPENAI -ErrorAction SilentlyContinue
        { Invoke-OpenAI -Prompt "hi" -Model "gpt-4o-mini" } | Should -Throw
        $env:LLM_API_KEY_OPENAI = "test-key"
    }

    It "should log message when called" {
        # ✅ ログバッファをリセット
        $global:LLMLogBuffer = @()

        try {
            Invoke-OpenAI -Prompt "test message" -Model "gpt-4o-mini"
        } catch {
            # エラーは無視（実際のAPI呼び出しは不要）
        }

        # ✅ ログ出力に "Invoke-OpenAI" が含まれるか検証
        ($global:LLMLogBuffer | Out-String) | Should -Match "Invoke-OpenAI"
    }
}
