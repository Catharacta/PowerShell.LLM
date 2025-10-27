param(
    [string]$IssuesPath = "../issues"
)

# スクリプトの絶対パスを取得
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$TargetPath = Join-Path $ScriptDir $IssuesPath

# === phase フォルダ一覧を取得 ===
$phases = Get-ChildItem -Path $TargetPath -Directory -Filter "phase*" -ErrorAction SilentlyContinue |
    Sort-Object Name |
    ForEach-Object { $_.Name }

# === 出力ロジック ===
if (-not $phases -or $phases.Count -eq 0) {
    Write-Output "[]"
}
else {
    # どんな場合でも JSON 形式で出す（常に配列）
    $json = $phases | ConvertTo-Json -Compress
    Write-Output $json
}
