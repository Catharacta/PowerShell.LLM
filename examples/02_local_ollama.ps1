Import-Module "$PSScriptRoot/../src/PowerShell.LLM.psm1" -Force

$response = Invoke-LLM -Provider ollama -Model "llama3" -Prompt "PowerShellでファイル一覧を表示するコマンド"
Write-Host "`n--- Ollama Response ---`n"
Write-Host $response
