# Gradle SSL エラー時の対処（Windows）

`flutter build appbundle --release` で次のようなエラーが出る場合:

```
PKIX path building failed: unable to find valid certification path
SSL handshake exception
```

## 試す順番

1. **VPN / プロキシをオフ**にして再実行
2. **別ネットワーク**（テザリング等）で再実行
3. Android Studio → **SDK Manager** で Android SDK / Build-Tools を更新
4. ターミナルで:
   ```powershell
   cd c:\Users\junki\golf_record_app
   flutter clean
   flutter pub get
   flutter build appbundle --release
   ```
5. 会社 PC の場合: IT 部門に「Gradle が `dl.google.com` / `repo.maven.apache.org` へ SSL 接続できない」と相談

## 成功の確認

```
build\app\outputs\bundle\release\app-release.aab
```

が生成されていれば OK。

## 補足

`flutter run`（debug）が成功しても、release ビルドだけ依存関係の再取得で失敗することがあります。
