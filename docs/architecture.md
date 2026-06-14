# アーキテクチャ — FeelShot アプリ

> 本ドキュメントは実装構成のソースオブトゥルース（SoT）です。

## 1. 技術スタック

| レイヤ | 技術 |
|--------|------|
| フレームワーク | Flutter 3.x |
| 言語 | Dart 3.12+ |
| UI | Material 3 |
| 永続化 | `shared_preferences` ^2.5.5 |
| 状態管理 | `StatefulWidget` + `setState` |
| テスト | `flutter_test` |

---

## 2. ディレクトリ構成

```
golf_record_app/
├── docs/                    # 要件・アーキテクチャ・TODO（本 SoT）
├── lib/
│   ├── main.dart            # エントリポイント、MaterialApp 設定
│   ├── constants/
│   │   └── tag_options.dart # 固定タグ一覧
│   ├── models/
│   │   └── record.dart      # Record モデル、SessionType、JSON 変換
│   ├── pages/
│   │   ├── record_list_page.dart   # 一覧・フィルタ・CRUD オーケストレーション
│   │   ├── record_form_page.dart   # 作成・編集フォーム
│   │   └── record_detail_page.dart # 詳細・削除
│   ├── services/
│   │   └── record_storage.dart     # shared_preferences ラッパー
│   ├── utils/
│   │   ├── date_formatter.dart     # 日付表示フォーマット
│   │   ├── club_tag_utils.dart     # ウッド/アイアン/アプローチタグの変換・フィルタ
│   │   └── iron_tag_utils.dart     # club_tag_utils への re-export
│   └── widgets/
│       └── record_card.dart        # 一覧カード UI
├── test/
│   └── widget_test.dart     # 起動スモークテスト
└── pubspec.yaml
```

---

## 3. レイヤ構成

```
┌─────────────────────────────────────────┐
│  Presentation (pages / widgets)         │
│  RecordListPage, RecordFormPage, ...    │
└─────────────────┬───────────────────────┘
                  │ Record / callbacks
┌─────────────────▼───────────────────────┐
│  Domain (models)                        │
│  Record, SessionType                    │
└─────────────────┬───────────────────────┘
                  │ toJson / fromJson
┌─────────────────▼───────────────────────┐
│  Data (services)                        │
│  RecordStorage → shared_preferences     │
└─────────────────────────────────────────┘
```

MVP では Repository パターン等は採用せず、**一覧画面がストレージを直接保持**するシンプル構成。

---

## 4. コンポーネント責務

### 4.1 `main.dart`

- `GolfRecordApp`: `MaterialApp` 定義
- ホーム: `RecordListPage`
- テーマ: `ColorScheme.fromSeed(seedColor: Colors.green)`

### 4.2 `RecordListPage`（状態の中心）

- 記録リスト `_records` をメモリ上で保持
- `RecordStorage` 経由で読み込み / 保存
- CRUD コールバックを子画面に渡す
  - `_saveRecord` → 作成・更新
  - `_deleteRecord` → 削除
- フィルタ状態（`_typeFilter`, `_tagFilter`）を管理
- ナビゲーション: `Navigator.push` + `MaterialPageRoute`

### 4.3 `RecordFormPage`

- フォーム入力・バリデーション
- 新規: `initialRecord == null`
- 編集: `initialRecord` からプリセット
- 保存: `onSave(Record)` コールバック → `Navigator.pop`

### 4.4 `RecordDetailPage`

- 読み取り専用表示
- 編集: `RecordFormPage` へ push
- 削除: 確認ダイアログ → `onDelete(id)` → `Navigator.pop`

### 4.5 `RecordStorage`

```dart
loadRecords()  → List<Record>  // JSON デシリアライズ、date 降順
saveRecords()  → void          // JSON シリアライズ
```

- ストレージキー: `records_v1`

### 4.6 `Record` モデル

- イミュータブルなデータクラス
- `copyWith`, `toJson`, `fromJson`
- `SessionType`: `practice` | `round`

---

## 5. データフロー

### 5.1 起動時

```
main()
  → RecordListPage.initState()
    → RecordStorage.loadRecords()
      → shared_preferences.getString('records_v1')
        → jsonDecode → Record.fromJson × N
    → setState(_records)
```

### 5.2 保存時（作成 / 更新）

```
RecordFormPage._submit()
  → onSave(record)          // RecordListPage._saveRecord
    → setState(_records)    // メモリ更新 + 日付ソート
    → _persistRecords()
      → RecordStorage.saveRecords()
        → jsonEncode → shared_preferences.setString
  → Navigator.pop
```

### 5.3 削除時

```
RecordDetailPage._confirmDelete()
  → onDelete(id)            // RecordListPage._deleteRecord
    → setState(_records.remove)
    → _persistRecords()
  → Navigator.pop
```

---

## 6. 永続化フォーマット

**キー:** `records_v1`

**値（JSON 配列）例:**

```json
[
  {
    "id": "1735689600000000",
    "date": "2026-05-28T00:00:00.000",
    "type": "practice",
    "goodFeel": "テイクバックがゆっくり",
    "missCause": "体が早く開いた",
    "nextTry": "フィニッシュまで待つ",
    "tags": ["アイアン", "メンタル"],
    "memo": "",
    "createdAt": "2026-05-28T12:00:00.000",
    "updatedAt": "2026-05-28T12:00:00.000"
  }
]
```

- スキーマ変更時はキーを `records_v2` 等に上げ、マイグレーションを検討

---

## 7. ナビゲーション

- **方式:** 命令的ナビゲーション（`Navigator.push` / `pop`）
- **ルーター:** 未使用（go_router 等なし）
- **戻るボタン:** Flutter `AppBar` 自動生成（一覧以外）

**スタック例（詳細 → 編集）:**

```
[RecordListPage] → [RecordDetailPage] → [RecordFormPage]
```

---

## 8. UI コンポーネント

### `RecordCard`

- 種別バッジ（練習: teal / ラウンド: indigo）
- 日付: `formatRecordDate()` → `2026年5月28日（水）`
- タイトル: `goodFeel`（最大2行）
- サブ: `次回: {nextTry}`
- タグ: チップ表示

### フィルタバー

- `SegmentedButton<SessionType?>`: 全部 / 練習 / ラウンド
- `FilterChip`: 固定タグ（単一選択、再タップで解除）
- アイアン選択時: 番手 `FilterChip`（3〜9）を追加表示

> **アイアンフィルタ:** `recordMatchesTagFilter()` により、`アイアン` のみ選択時は `アイアン` / `X番アイアン` の両方にマッチ。番手指定時は `X番アイアン` の完全一致。

---

## 9. 依存関係

```
main.dart
  └── record_list_page.dart
        ├── record_detail_page.dart
        │     └── record_form_page.dart
        ├── record_form_page.dart
        ├── record_storage.dart
        │     └── record.dart
        ├── record_card.dart
        │     ├── record.dart
        │     └── date_formatter.dart
        └── tag_options.dart

record_form_page.dart
  ├── record.dart
  └── tag_options.dart
```

---

## 10. テスト

| ファイル | 内容 |
|----------|------|
| `test/widget_test.dart` | `GolfRecordApp` 起動、タイトル・FAB 存在確認 |
| `test/iron_tag_utils_test.dart` | アイアンタグ変換・フィルタ・フォーム復元 |

> ストレージ・フォーム・フィルタのユニット/ウィジェットテストは未整備。

---

## 11. 将来のアーキテクチャ検討

| タイミング | 検討事項 |
|-----------|----------|
| 画面・状態が増えたとき | `ChangeNotifier` / Riverpod 等への移行 |
| 記録件数が増えたとき | `sqflite` / `drift` への移行 |
| 画面遷移が複雑化 | `go_router` 導入 |
| タグ詳細（番号等） | `tagDetails: Map<String, String>` または派生タグ文字列 |

---

## 12. 変更履歴

| 日付 | 内容 |
|------|------|
| 2026-05 | 初版作成（MVP v1 実装反映） |
| 2026-05 | v1.1: `iron_tag_utils`、番手フィルタ追記 |
