# Android リリース手順

## 続きから（いまやること）

| 順番 | 作業 | 状態 |
|------|------|------|
| 1 | `android\create-keystore.ps1` を実行（パスワード設定） | ☐ 要実施 |
| 2 | `key.properties` を編集 | ☐ 要実施 |
| 3 | `flutter build appbundle --release` | ☐ 要実施 |
| 4 | 実機 or エミュで動作確認 | ☐ 要実施 |
| 5 | `docs/play-store-listing.md` を元に Play Console 登録 | ☐ 要実施 |
| 6 | `docs/PRIVACY.md` を Web 公開 | ☐ 要実施 |

ストア文案: [play-store-listing.md](play-store-listing.md)

---

## 1. 署名キー（初回のみ）

PowerShell（`android` フォルダで）:

```powershell
cd android
.\create-keystore.ps1
```

または手動:

```powershell
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

## 2. key.properties

```powershell
copy key.properties.example key.properties
```

`key.properties` を編集:

```properties
storePassword=（設定したパスワード）
keyPassword=（設定したパスワード）
keyAlias=upload
storeFile=upload-keystore.jks
```

`key.properties` と `*.jks` は Git に含めない（`.gitignore` 済み）。

## 3. リリースビルド

```powershell
cd c:\Users\junki\golf_record_app
flutter analyze
flutter test
flutter build appbundle --release
```

成果物: `build/app/outputs/bundle/release/app-release.aab`

`key.properties` が無い場合は debug キーで署名されます（Play 提出不可）。

## 4. Application ID

- **Play Store 用 ID:** `com.golfrecord.app`（`android/app/build.gradle.kts`）
- 公開後に変更不可のため、必要なら提出前に最終確認

## 5. 実機確認

```powershell
flutter install --release
```

## 6. Google Play 提出前

- [ ] スクリーンショット・説明文
- [ ] [docs/PRIVACY.md](PRIVACY.md) を Web 公開し、プライバシーポリシー URL を登録
- [ ] データセーフティ: 端末内保存のみ・サーバー送信なし

詳細チェックリスト: [release-checklist.md](release-checklist.md)
