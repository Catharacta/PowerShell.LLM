# tests/Commands/Invoke-LLM.Tests.ps1
# ===================================
Import-Module "$PSScriptRoot/../../src/PowerShell.LLM.psd1" -Force

Describe "Invoke-LLM" {
    Context "Mock provider" {
        It "should return a non-empty string for a valid prompt" {
            $result = Invoke-LLM -Prompt "Hello test" -Provider "mock"
            $result | Should -Not -BeNullOrEmpty
        }

        It "should throw for an unknown provider" {
            { Invoke-LLM -Prompt "Hello" -Provider "unknown" } | Should -Throw
        }
    }
}
