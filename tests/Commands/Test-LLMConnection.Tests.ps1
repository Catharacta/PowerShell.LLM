# tests/Commands/Test-LLMConnection.Tests.ps1
# ==========================================
Import-Module "$PSScriptRoot/../../src/PowerShell.LLM.psd1" -Force

Describe "Test-LLMConnection" {
    Context "Mock provider" {
        It "should return a success result for mock provider" {
            $result = Test-LLMConnection -Provider "mock"
            $result.Success | Should -BeTrue
        }
    }

    Context "Invalid provider" {
        It "should throw an error for unknown provider" {
            { Test-LLMConnection -Provider "invalid" } | Should -Throw
        }
    }
}
