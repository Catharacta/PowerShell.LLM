# 🤖 PowerShell.LLM

PowerShellスクリプトから **OpenAI** や **Ollama** などの LLM を呼び出すための軽量ライブラリ。

---

## 🚀 インストール
```powershell
git clone https://github.com/yourname/PowerShell.LLM.git
cd PowerShell.LLM
Import-Module ./src/PowerShell.LLM.psm1 -Force
```

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

---

## 📌 Documentation
- [ROADMAP.md](./ROADMAP.md) — 開発ロードマップ（中長期目標）
- [PROJECT_PLAN.md](./PROJECT_PLAN.md) — 実装計画・タスク進行表
