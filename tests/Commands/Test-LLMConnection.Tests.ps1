# tests/Commands/Test-LLMConnection.Tests.ps1
Describe "Test-LLMConnection" {
    Context "Mock provider" {
        It "should return a success result for mock provider" {
            $result = Test-LLMConnection -Provider "mock"
            $result.Success | Should -BeTrue
            $result.Message | Should -Match "successful"
        }
    }

    Context "Invalid provider" {
        It "should return a failure result for unknown provider" {
            $result = Test-LLMConnection -Provider "invalid"
            $result.Success | Should -BeFalse
            $result.Message | Should -Match "未対応|APIキー"
        }
    }
}
