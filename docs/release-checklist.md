# リリース前チェックリスト — ゴルフ感覚メモ

> 提出先: **App Store（iOS）**  
> コード対応済み項目には ✅ を付与

---

## 0. リリースブロッカー（iOS）

| # | 項目 | 状態 |
|---|------|------|
| 0-1 | Bundle ID `com.golfrecord.app` | ✅ |
| 0-2 | Xcode Signing Team 設定 | ✅ |
| 0-3 | Apple Developer Program 登録 | ☐ 要実施 |
| 0-4 | バージョン `pubspec.yaml` | ☐ 提出前に確認（現在 `1.0.0+1`） |
| 0-5 | `flutter build ipa --release` | ☐ 手動実行 |
| 0-6 | 実機 release テスト | ✅ 起動確認済み / ☐ CRUD 全項目 |

手順: [RELEASE_IOS.md](RELEASE_IOS.md)

---

## 1. クラッシュ対策

| # | 項目 | 状態 |
|---|------|------|
| 1-1 | 破損 JSON の読み込み耐障害 | ✅ `RecordStorage.loadRecords` + `Record.tryFromJson` |
| 1-2 | 不正 type / 日付 | ✅ フォールバック |
| 1-3 | 保存失敗の通知 | ✅ SnackBar |
| 1-4 | YouTube 起動失敗 | ✅ 既存（VideoSearchPage） |

---

## 2. コード整理

| # | 項目 | 状態 |
|---|------|------|
| 2-1 | `pubspec` description | ✅ 更新 |
| 2-2 | `lib/` の debug print | ✅ なし |

---

## 3. セキュリティ・プライバシー

| # | 項目 | 状態 |
|---|------|------|
| 3-1 | API キー・秘密情報 | ✅ なし |
| 3-2 | プライバシーポリシー草案 | ✅ `docs/PRIVACY.md` |
| 3-3 | プライバシーポリシー Web 公開 URL | ☐ 要実施 |
| 3-4 | お問い合わせメール記載 | ☐ 要実施 |
| 3-5 | App プライバシー申告（Connect） | ☐ 端末内のみ・収集なし |

---

## 4. デバッグ・ビルド

| # | 項目 | 状態 |
|---|------|------|
| 4-1 | `debugShowCheckedModeBanner: false` | ✅ |
| 4-2 | 提出ビルドは release / ipa | ☐ 手動 |
| 4-3 | iOS 26 実機は debug 不可 → release 使用 | ✅ 手順書に記載 |

---

## 5. UI / バリデーション

| # | 項目 | 状態 |
|---|------|------|
| 5-1 | 必須3項目 300 文字上限 | ✅ |
| 5-2 | メモ 1000 文字上限 | ✅ |
| 5-3 | スモークテスト（一覧・CRUD・フィルタ・YouTube） | ☐ 手動 |

---

## 6. 品質ゲート

```bash
flutter analyze
flutter test
flutter build ipa --release
```

---

## 7. App Store Connect（手動）

- [ ] アプリ新規登録（Bundle ID 紐付け）
- [ ] スクリーンショット（6.7" 必須）
- [ ] 説明文・キーワード（[app-store-listing.md](app-store-listing.md)）
- [ ] プライバシーポリシー URL
- [ ] サポート URL
- [ ] ビルドアップロード・審査提出

---

## 8. v1.1 以降（リリース後でも可）

- 前回の「次回試すこと」強調表示
- 番手別飛距離の記録・平均表示
- 記録の並び替え

---

## 9. 将来 v2（サブスク）

- ユーザーアカウント / クラウド同期
- StoreKit / サブスクリプション
- 利用規約・課金に関するプライバシー更新

---

## 参考: Android（提出見送り）

Android 向け手順: [RELEASE_ANDROID.md](RELEASE_ANDROID.md)  
Play 文案: [play-store-listing.md](play-store-listing.md)
