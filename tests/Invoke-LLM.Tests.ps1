# tests/Invoke-LLM.Tests.ps1
# Pester v5 以降対応

#----------------------------------------
# テスト対象: Invoke-LLM
#----------------------------------------

# モジュールを読み込む（相対パス）
Import-Module "$PSScriptRoot/../src/PowerShell.LLM.psd1" -Force

Describe "Invoke-LLM 基本動作テスト" {

    BeforeAll {
        # モック用のプロンプト
        $TestPrompt = "Hello, PowerShell!"
    }

    Context "基本的な呼び出し" {

        It "Invoke-LLM コマンドが存在すること" {
            Get-Command Invoke-LLM | Should -Not -BeNullOrEmpty
        }

        It "モック呼び出しが成功すること" {
            $result = Invoke-LLM -Prompt $TestPrompt -Provider "mock"
            $result | Should -BeOfType [string]
            $result | Should -Match "Mock response"
        }
    }

    Context "異常系のテスト" {

        It "Prompt が指定されていない場合は例外を投げること" {
            { Invoke-LLM } | Should -Throw
        }

        It "無効な Provider が指定された場合にエラーを出すこと" {
            { Invoke-LLM -Prompt $TestPrompt -Provider "UnknownAI" } | Should -Throw
        }
    }

    Context "出力の検証" {
        It "モック出力に 'PowerShell' が含まれること" {
            $result = Invoke-LLM -Prompt $TestPrompt -Provider "mock"
            $result | Should -Match "PowerShell"
        }
    }
}
