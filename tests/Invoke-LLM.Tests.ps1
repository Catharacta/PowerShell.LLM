Import-Module "$PSScriptRoot/../src/PowerShell.LLM.psm1" -Force

Describe "Invoke-LLM 基本テスト" {
    It "OpenAI呼び出しが失敗しても例外を投げない" {
        $result = { Invoke-LLM -Prompt "test" } | Should -Not -Throw
    }

    It "Ollama呼び出しで結果を返す（モック）" {
        Mock Invoke-Ollama { return "mock response" }
        $result = Invoke-LLM -Prompt "test" -Provider ollama
        $result | Should -Be "mock response"
    }
}
