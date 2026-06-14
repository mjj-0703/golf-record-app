# iOS リリース手順 — App Store 提出

> 対象: ゴルフ感覚メモ（`com.golfrecord.app`）  
> 開発環境: Mac + Flutter + Xcode

---

## 続きから（いまやること）

| 順番 | 作業 | 状態 |
|------|------|------|
| 1 | [Apple Developer Program](https://developer.apple.com/programs/) 登録（年 $99） | ☐ 要実施 |
| 2 | Xcode で Signing Team 設定（`ios/Runner.xcworkspace`） | ✅ 設定済み |
| 3 | 実機で release 動作確認 | ✅ 確認済み（`flutter run -d MJ --release`） |
| 4 | `flutter build ipa --release` | ☐ 要実施 |
| 5 | App Store Connect にアプリ登録・ipa アップロード | ☐ 要実施 |
| 6 | [app-store-listing.md](app-store-listing.md) を元に掲載情報入力 | ☐ 要実施 |
| 7 | [PRIVACY.md](PRIVACY.md) を Web 公開 | ☐ 要実施 |

掲載文案: [app-store-listing.md](app-store-listing.md)  
チェックリスト: [release-checklist.md](release-checklist.md)

---

## 1. 前提

| 項目 | 値 |
|------|-----|
| Bundle ID | `com.golfrecord.app` |
| 表示名 | ゴルフ感覚メモ |
| バージョン | `pubspec.yaml` の `version`（例: `1.0.0+1`） |
| 最小 iOS | Flutter プロジェクト既定（Xcode で確認） |

### 開発時の注意（iOS 26 実機）

- **debug モード**（`flutter run`）は iOS 26 実機でデバッガ接続に失敗することがある
- **実機確認・提出用ビルド**は `--release` または `flutter build ipa` を使用
- 日常開発は **シミュレータ + debug**、実機は **release** で確認

```bash
# 実機（例: MJ）
flutter run -d MJ --release

# シミュレータ
flutter run
```

---

## 2. Apple Developer / Xcode 署名（初回）

### 2-1. Apple Developer Program

1. https://developer.apple.com/programs/ で登録
2. 登録完了後、Xcode → **Settings → Accounts** で Apple ID を追加

### 2-2. Xcode で署名

```bash
open ios/Runner.xcworkspace
```

1. 左 **Runner**（青アイコン）→ **TARGETS → Runner**
2. **Signing & Capabilities**
3. **Automatically manage signing** を ON
4. **Team** で Developer Program のチームを選択
5. **Bundle Identifier** が `com.golfrecord.app` であることを確認

`ios/Runner.xcodeproj/project.pbxproj` に Team ID が保存されます（Git に含まれる場合あり）。

### 2-3. 実機の初回設定

- **デベロッパモード**を有効化（設定 → プライバシーとセキュリティ）
- インストール後 **設定 → 一般 → VPNとデバイス管理** で開発者を信頼
- 初回起動時 **ローカルネットワーク** を許可（debug 時）

---

## 3. アイコン

`pubspec.yaml` で `flutter_launcher_icons` 設定済み。Mac で生成:

```bash
dart run flutter_launcher_icons
```

生成後、シミュレータまたは実機でホーム画面のアイコンを確認。

---

## 4. 品質ゲート

```bash
cd /path/to/golf-record-app
flutter analyze
flutter test
flutter build ipa --release
```

成果物: `build/ios/ipa/*.ipa`（または Xcode Organizer 経由）

### 実機スモークテスト（release）

- [ ] 一覧表示・空状態
- [ ] 記録の作成・編集・削除
- [ ] 種別・タグフィルタ
- [ ] アプリ再起動後も記録が残る
- [ ] 詳細画面の「YouTubeで直し方を探す」

---

## 5. App Store Connect 登録

### 5-1. アプリの新規作成

1. https://appstoreconnect.apple.com/
2. **マイ App → ＋ → 新規 App**
3. プラットフォーム: iOS
4. 名前: **ゴルフ感覚メモ**
5. プライマリ言語: 日本語
6. Bundle ID: `com.golfrecord.app`
7. SKU: 任意（例: `golfrecord-app-001`）

### 5-2. ipa のアップロード

**方法 A: Flutter CLI**

```bash
flutter build ipa --release
```

Xcode **Organizer**（Window → Organizer）から **Distribute App → App Store Connect** でも可。

**方法 B: Xcode**

1. `open ios/Runner.xcworkspace`
2. 実機または **Any iOS Device** を選択
3. **Product → Archive**
4. **Distribute App → App Store Connect**

### 5-3. 審査用情報

| 項目 | 内容 |
|------|------|
| プライバシーポリシー URL | `PRIVACY.md` を公開した URL（必須） |
| カテゴリ | スポーツ または 仕事効率化 |
| 年齢制限 | 4+（想定） |
| 著作権 | © 2026 （氏名または屋号） |

### 5-4. App プライバシー（データ収集の申告）

本アプリ v1.0 の想定:

- **データを収集しない**（自前サーバーなし、端末内のみ）
- YouTube 検索はユーザ操作で外部アプリ起動（本アプリは API 未使用）

App Store Connect のプライバシー質問では「開発者が自社サーバーに送るデータなし」として回答。

---

## 6. スクリーンショット

詳細: [app-store-listing.md](app-store-listing.md)

シミュレータで撮影する例:

```bash
open -a Simulator
flutter run
# Cmd+S でスクリーンショット保存
```

必須サイズは App Store Connect 上の指示に従う（iPhone 6.7" 等）。

---

## 7. 審査提出

1. App Store Connect でビルドをバージョンに紐付け
2. 説明文・スクリーンショット・プライバシー URL を入力
3. **審査用メモ**（任意）: ログイン不要、端末内保存のみ
4. **提出**

審査は通常 1〜3 日程度（変動あり）。

---

## 8. リリース後

- `pubspec.yaml` の `version` を更新（例: `1.0.1+2`）
- リリースノートを [app-store-listing.md](app-store-listing.md) に追記
- クラッシュ・レビューは App Store Connect で確認

---

## 9. トラブルシューティング

| 症状 | 対処 |
|------|------|
| No valid code signing certificates | Xcode → Team 選択、Apple ID ログイン |
| Dart VM Service not discovered（実機 debug） | `--release` を使用 |
| 黒画面に英語テキスト（実機 debug） | iOS 26 + debug の既知問題 → `--release` |
| Automation / Xcode 権限 | システム設定 → プライバシー → 自動化 |
| `flutter` not found | `source ~/.zprofile`（Homebrew PATH） |

---

## 10. 将来（サブスク v2 以降）

v1.0 は無料・ローカルのみ。サブスク導入時は追加で必要:

- StoreKit / RevenueCat 等
- 利用規約・サブスク説明
- App Store Connect のサブスクリプション登録
- プライバシーポリシー更新（アカウント・課金データ）
- 復元購入（Restore Purchases）

詳細は v2 設計時に [todo.md](todo.md) を更新。
