@{
    RootModule        = 'PowerShell.LLM.psm1'
    ModuleVersion     = '0.1.0'
    GUID              = 'b4a8e2b5-7a31-4c92-8e1f-5ad88f76c1a1'
    Author            = 'Your Name'
    Description       = 'PowerShellからLLM (OpenAI / Ollama) を呼び出すための軽量ライブラリ'
    FunctionsToExport = @(
    'Clear-LLMLogCache' 
    'Flush-LLMLogs' 
    'Get-LLMConfig' 
    'Get-LLMLogHistory' 
    'Handle-LLMError' 
    'Invoke-Anthropic' 
    'Invoke-AzureOpenAI' 
    'Invoke-LLM' 
    'Invoke-MockLLM' 
    'Invoke-Ollama' 
    'Invoke-OpenAI' 
    'Set-LLMLogLevel' 
    'Test-LLMConnection' 
    'Write-LLMLog'
)
    RequiredModules   = @()
    PowerShellVersion = '7.0'
}


