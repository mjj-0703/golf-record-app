# 初回のみ実行: Play 提出用 keystore を作成します。
# パスワードは対話入力されます（チャットや Git に保存しないでください）。

$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

$keystore = "upload-keystore.jks"
if (Test-Path $keystore) {
    Write-Host "既に $keystore があります。上書きする場合は手動で削除してから再実行してください。"
    exit 1
}

Write-Host "=== upload-keystore.jks を作成します ==="
Write-Host "名前・組織などは keytool の質問に答えてください（開発用なら適当で可）。"
Write-Host ""

keytool -genkey -v `
    -keystore $keystore `
    -keyalg RSA `
    -keysize 2048 `
    -validity 10000 `
    -alias upload

if (-not (Test-Path "key.properties")) {
    Copy-Item "key.properties.example" "key.properties"
    Write-Host ""
    Write-Host "key.properties をコピーしました。"
    Write-Host "storePassword / keyPassword / storeFile を編集してください。"
}

Write-Host ""
Write-Host "完了。次: cd .. して flutter build appbundle --release"
