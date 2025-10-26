Import-Module "$PSScriptRoot/../src/PowerShell.LLM.psm1" -Force

$env:OPENAI_API_KEY = "sk-..."  # ←自分のキーを設定

$response = Invoke-LLM -Prompt "PowerShellで現在時刻を表示する方法を教えて"
Write-Host "`n--- AI Response ---`n"
Write-Host $response
