# 🚀 PowerShell.LLM 開発プロジェクト計画（GitHub Projects 用）

> この計画は、[ROADMAP.md](./ROADMAP.md) に基づいて  
> **マイルストーン → Issue → 実装タスク** の順に GitHub Projects へ登録するためのテンプレートです。

---

## 🗂 マイルストーン一覧

| マイルストーン | 期間 | 概要 |
|----------------|------|------|
| **M1. コア機能実装** | 〜2か月 | Invoke-LLM 基礎構築・OpenAI/Ollama対応 |
| **M2. 拡張機能追加** | 2〜4か月 | 設定・テンプレート・ストリーム出力 |
| **M3. チャット対応** | 4〜6か月 | セッション／履歴管理・チャット構造 |
| **M4. RAG実装** | 6〜9か月 | 外部データ読込・ベクトル検索対応 |
| **M5. 運用強化・CI/CD** | 9〜12か月 | 自動テスト・リリース・品質管理 |

---

## 🧩 各マイルストーンのタスク構成

### 🥇 M1. コア機能実装
**目的**：LLMを統一インターフェースで呼び出せる最小限の機能を構築

#### Issues
- [ ] `Invoke-LLM` コマンドレットを実装
- [ ] OpenAI Provider 実装 (`src/Providers/OpenAI.psm1`)
- [ ] Ollama Provider 実装 (`src/Providers/Ollama.psm1`)
- [ ] 設定ファイル・環境変数管理（APIキー格納）
- [ ] エラーハンドリング（例外・タイムアウト処理）
- [ ] Pester テスト (`tests/Invoke-LLM.Tests.ps1`)
- [ ] CI Workflow (test.yml) の雛形追加
- [ ] README.md に使用例を追記

📘 **完了条件**
- `Invoke-LLM` が複数プロバイダーで動作
- CI テスト成功

---

### 🥈 M2. 拡張機能追加
**目的**：ユーザー体験の向上・柔軟な設定機能の追加

#### Issues
- [ ] `Get-LLMModels` コマンドレット実装
- [ ] ストリーミング出力対応 (`-Stream` オプション)
- [ ] プロンプトテンプレート機構 (`templates/*.json`)
- [ ] 出力フォーマットオプション (`-AsJson`, `-AsMarkdown`)
- [ ] APIリトライ・レート制御ロジック
- [ ] 設定操作用コマンド (`Set-LLMConfig`, `Get-LLMConfig`)
- [ ] examples/ に応用スクリプト追加
- [ ] テスト (`tests/Template.Tests.ps1`)

📘 **完了条件**
- ユーザーフレンドリーな CLI 体験  
- 全テストパス・CIで自動実行

---

### 🥉 M3. チャット対応
**目的**：PowerShell 上でセッション型 LLM チャットを可能にする

#### Issues
- [ ] `New-LLMSession`, `Add-LLMMessage`, `Invoke-LLMChat` 実装
- [ ] 会話履歴の永続化（JSON保存）
- [ ] system/user/assistant ロール管理
- [ ] トークン制限・履歴切り捨て機能
- [ ] チャットUI整形（色付きログなど）
- [ ] Sessionテスト (`tests/Session.Tests.ps1`)

📘 **完了条件**
- チャット履歴の再利用が可能  
- ChatGPT風の対話が実現

---

### 🏅 M4. RAG実装
**目的**：外部ドキュメントを利用した知識拡張（Retrieval-Augmented Generation）

#### Issues
- [ ] `Add-LLMContext -Path` 機能実装（ドキュメント読込）
- [ ] 簡易ベクトル検索（FAISS/Chroma対応）
- [ ] コンテキスト結合生成パイプライン
- [ ] CSV/JSON/Markdown解析
- [ ] プロンプトチェーン対応（前回結果を次に渡す）
- [ ] テスト (`tests/RAG.Tests.ps1`)

📘 **完了条件**
- PowerShell内で RAG フローが動作  
- 外部ドキュメント参照による生成が可能

---

### 🧠 M5. 運用強化・CI/CD
**目的**：リリース自動化・品質管理の最適化

#### Issues
- [ ] 実行ログ・監査保存 (`~/.config/powershell.llm/logs/`)
- [ ] トークン／コストトラッキング
- [ ] 設定GUI（Windows.Forms or WPF）
- [ ] GitHub Actions で自動リリース（PowerShell Gallery公開）
- [ ] PSScriptAnalyzer チェック導入
- [ ] セマンティックリリース・CHANGELOG自動生成
- [ ] CI結果バッジを README に追加

📘 **完了条件**
- CI/CDが自動稼働  
- PowerShell Gallery に自動公開

---

## 🧱 推奨 GitHub Projects カラム構成

| カラム | 用途 |
|--------|------|
| 📝 **Backlog** | 未着手・検討中のアイデア |
| 🧩 **In Progress** | 実装中の Issue |
| 🧪 **Testing** | テスト中／PRレビュー中 |
| ✅ **Done** | マージ・完了済み |
| 🚀 **Released** | リリース反映済み機能 |

---

## 🧩 Issue テンプレート例（`.github/ISSUE_TEMPLATE/feature_request.yml`）

```yaml
name: "💡 機能追加提案"
description: "新しいコマンドや機能を提案する"
title: "[Feature] <機能名>"
labels: ["feature", "enhancement"]
body:
  - type: input
    id: summary
    attributes:
      label: 概要
      placeholder: どんな機能を追加したいですか？
  - type: textarea
    id: motivation
    attributes:
      label: 背景／目的
      placeholder: なぜ必要か、どのように使うかを説明してください。
  - type: textarea
    id: spec
    attributes:
      label: 提案内容
      placeholder: 実装案・サンプルコードなどがあれば記載してください。
