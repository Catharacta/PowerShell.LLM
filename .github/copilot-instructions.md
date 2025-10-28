# 🤖 GitHub Copilot Instructions for PowerShell.LLM

> このファイルは、Copilot が **PowerShell.LLM** プロジェクトの開発方針・コード規約・補助ルールを理解し、  
> 一貫した提案を行うための設定です。  
> 主に Visual Studio Code / GitHub Copilot Chat / Copilot CLI で参照されます。

---

## 🧭 プロジェクト概要

**PowerShell.LLM** は、PowerShell からさまざまな LLM（Large Language Model）を簡潔かつ統一的に利用できるようにするモジュールです。  
OpenAI / Ollama / Azure OpenAI / HuggingFace などのプロバイダーを統一インターフェースで扱い、  
スクリプトや自動化フローの中で自然言語処理を活用できることを目指します。

---

## 🧱 フォルダ構成

PowerShell.LLM/
├── .gitignore
├── PROJECT_PLAN.md
├── README.md
├── ROADMAP.md
│
├── .github/
│   ├── copilot-instructions.md
│   └── workflows/
│       └── ci.yml
│
├── .vscode/
│   ├── settings.json
│   └── tasks.json
│
├── automation/
│   ├── create_issues_from_yaml.ps1
│   ├── get_phase_list.ps1
│   └── run_with_phase.ps1
│
├── examples/
│   ├── 01_basic.ps1
│   └── 02_local_ollama.ps1
│
├── issues/
│   ├── phase2/
│   │   ├── github-project-import.yml
│   │   └── project-config.yml
│   │
│   └── phase3/
│
├── src/
│   ├── PowerShell.LLM.psd1
│   ├── PowerShell.LLM.psm1
│   │
│   ├── Commands/
│   │   ├── Get-LLMProvider.ps1
│   │   ├── Invoke-LLM.ps1
│   │   ├── New-LLMPromptTemplate.ps1
│   │   └── Test-LLMConnection.ps1
│   │
│   ├── Core/
│   │   ├── Config.ps1
│   │   ├── ErrorHandling.ps1
│   │   ├── Logger.ps1
│   │   └── Utils.ps1
│   │
│   ├── Data/
│   │   ├── config.sample.json
│   │   └── cache/
│   │       └── history.json
│   │
│   ├── Providers/
│   │   ├── Anthropic.ps1
│   │   ├── AzureOpenAI.ps1
│   │   ├── MockLLM.ps1
│   │   ├── Ollama.ps1
│   │   └── OpenAI.ps1
│   │
│   └── Templates/
│       ├── custom/
│       │   └── mytemplate.txt
│       │
│       └── default/
│           ├── chat.txt
│           └── summarize.txt
│
└── tests/
    └── Invoke-LLM.Tests.ps1



---

## 🎯 開発方針

- コマンドレット名は **`Verb-Noun`** 形式（例：`Invoke-LLM`, `Get-LLMModels`）
- 各 Provider は `src/Providers/` 以下で独立したモジュールとして実装
- すべてのエクスポート関数は **明示的に `Export-ModuleMember` で定義**
- 外部APIキーは環境変数または設定ファイル (`~/.config/powershell.llm/config.json`) で管理
- `tests/` 以下の Pester テストは CI に統合される（GitHub Actions）

---

## 🧩 主なコマンドレット設計方針

| コマンド | 概要 | 備考 |
|-----------|------|------|
| `Invoke-LLM` | 任意のプロンプトを送信し応答を取得 | プロバイダー抽象化レイヤーを利用 |
| `Get-LLMModels` | 利用可能なモデル一覧を取得 | OpenAI / Ollama / Azure共通 |
| `Set-LLMConfig` | 設定ファイル更新 | APIキー・モデル・既定プロバイダー設定 |
| `New-LLMSession` | セッションを開始し、履歴管理を初期化 | チャット対応用 |
| `Add-LLMMessage` | セッションにメッセージを追加 | system/user/assistant |
| `Invoke-LLMChat` | 会話形式でLLMを呼び出す | 履歴ベースの応答生成 |

---

## 🧠 Copilot 提案ポリシー

> Copilot がコード補完・PR支援・コメント提案を行う際のルール。

1. **PowerShell のベストプラクティスを優先**
   - Verb-Noun 構文を維持
   - 明確なパラメータ定義 (`[Parameter()]` 属性付き)
   - Pipeline入力に対応する場合は `[ValueFromPipeline]` を明示

2. **プロバイダー実装は共通インターフェースを遵守**
   - 各 `Provider` は以下の関数を必須実装：
     ```powershell
     function Get-ProviderInfo { ... }
     function Invoke-ProviderRequest($Prompt, $Model, $Options) { ... }
     ```
   - Copilot 提案時はこの構造を維持すること

3. **テスト駆動開発を推奨**
   - 新規関数には `tests/` に対応する `.Tests.ps1` ファイルを生成
   - Pester 構文を用いて `Describe` → `Context` → `It` 構造を維持

4. **ドキュメント整備を常に意識**
   - 各関数には PowerShell ヘルプコメント (`<# .SYNOPSIS ... #>`) を付与
   - README と examples の整合性を保つ

5. **コードスタイル**
   - 変数名は camelCase、関数名は PascalCase
   - 行コメントには `#` で短く意図を記載
   - JSON, YAML, Markdown ファイルは UTF-8 BOMなしで保存

---

## 🔍 テスト / CI / CD

- CI: GitHub Actions で `Invoke-Pester` 実行  
- Lint: `Invoke-ScriptAnalyzer` で構文・スタイル検証  
- CD: タグ `vX.Y.Z` 作成で自動的に PowerShell Gallery にリリース  
- Pull Request 時にテストが全て通過しない場合、マージ不可  

---

## 🧪 Copilot が支援すべき主な領域

| カテゴリ | Copilot が行うべき提案例 |
|-----------|---------------------------|
| **関数実装** | 新しい LLM Provider の関数テンプレート生成 |
| **テスト作成** | Pester テストスケルトン自動生成 |
| **ドキュメント整備** | ヘルプコメント雛形の補完 |
| **CI/CD** | YAMLワークフローの生成と修正提案 |
| **例示スクリプト** | examples/ 以下の利用例作成 |
| **型補完** | パラメータ属性 (`[ValidateSet()]`, `[switch]` など) の自動補完 |

---

## 🧩 Copilot チャットでの推奨プロンプト例

```text
@workspace
PowerShell.LLM の新しい Provider を追加したい。
OpenAI.psm1 の構造に沿って Anthropic.psm1 を作成して。

---

@workspace
Invoke-LLM に `-Stream` オプションを追加したい。
出力をリアルタイムに表示するサンプルを提案して。

---

@workspace
tests/Session.Tests.ps1 を生成して。
New-LLMSession と Add-LLMMessage の基本的な動作をカバーして。
