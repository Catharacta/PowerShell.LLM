# 🤖 PowerShell.LLM

PowerShellスクリプトから **OpenAI** や **Ollama** などの LLM を呼び出すための軽量ライブラリ。

---

## 🚀 インストール

git clone https://github.com/yourname/PowerShell.LLM.git
cd PowerShell.LLM
Import-Module ./src/PowerShell.LLM.psm1 -Force

---

## 💡 使用例

### 🔹 OpenAI
```powershell
$env:OPENAI_API_KEY = "sk-..."
Invoke-LLM -Prompt "PowerShellで今日の日付を表示するスクリプトを教えて"
```

### 🔹 Ollama
```powershell
Invoke-LLM -Provider ollama -Model "llama3" -Prompt "JSONを読み込むPowerShellスクリプトを作って"
```