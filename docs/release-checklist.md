# リリース前チェックリスト — ゴルフ感覚メモ

> コード対応済み項目には ✅ を付与（2026-06 時点）

---

## 0. リリースブロッカー

| # | 項目 | 状態 |
|---|------|------|
| 0-1 | Application ID を `com.example` 以外に | ✅ `com.golfrecord.app` |
| 0-2 | リリース署名設定 | ✅ `key.properties` + `RELEASE_ANDROID.md`（**キー作成は手動**） |
| 0-3 | バージョン `pubspec.yaml` | ☐ 提出前に確認（現在 `1.0.0+1`） |
| 0-4 | `flutter build appbundle --release` | ☐ 手動実行 |
| 0-5 | 実機テスト | ☐ 手動 |

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

## 3. セキュリティ

| # | 項目 | 状態 |
|---|------|------|
| 3-1 | API キー・秘密情報 | ✅ なし |
| 3-2 | プライバシーポリシー草案 | ✅ `docs/PRIVACY.md`（**Web 公開は手動**） |
| 3-3 | INTERNET 権限 | ✅ YouTube 検索用のみ |

---

## 4. デバッグ

| # | 項目 | 状態 |
|---|------|------|
| 4-1 | `debugShowCheckedModeBanner: false` | ✅ |
| 4-2 | ストア提出は release AAB | ☐ 手動 |

---

## 5. UI / バリデーション

| # | 項目 | 状態 |
|---|------|------|
| 5-1 | 必須3項目 300 文字上限 | ✅ |
| 5-2 | メモ 1000 文字上限 | ✅ |
| 5-3 | スモークテスト（一覧・CRUD・フィルタ・YouTube） | ☐ 手動 |

---

## 6. 品質ゲート

```powershell
flutter analyze
flutter test
flutter build appbundle --release
```

---

## 7. Play Store（手動）

- [ ] スクリーンショット
- [ ] 説明文
- [ ] プライバシーポリシー URL（`PRIVACY.md` を公開）
- [ ] データセーフティ申告

---

## 8. 保留機能（v1.1 以降）

- 番手別飛距離の記録・平均表示
- 前回の「次回試すこと」強調表示
