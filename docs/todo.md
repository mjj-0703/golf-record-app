# TODO — FeelShot アプリ

> 本ドキュメントは開発タスクのソースオブトゥルース（SoT）です。  
> 完了した項目は ✅、未着手は ⬜、進行中は 🔄 で管理してください。

---

## 完了（MVP v1）

### 基盤

- ✅ Flutter プロジェクト作成
- ✅ Android エミュレータでの起動確認
- ✅ ローカル永続保存（`shared_preferences`）
- ✅ 工程8: 再起動後も記録が残ることを確認

### 機能（工程1〜11）

- ✅ 記録一覧画面
- ✅ 記録作成画面
- ✅ 記録詳細画面
- ✅ 記録編集
- ✅ 必須項目バリデーション
- ✅ 記録削除（確認ダイアログ）
- ✅ UI 改善（カード、日付フォーマット、空状態）
- ✅ 種別フィルタ（全部 / 練習 / ラウンド）
- ✅ タグフィルタ
- ✅ アイアン番手選択・フィルタ
- ✅ ウッド番手選択・フィルタ
- ✅ ユーティリティ番手選択・フィルタ
- ✅ アプローチ種類選択・フィルタ

### ドキュメント

- ✅ `docs/requirements.md` 作成
- ✅ `docs/architecture.md` 作成
- ✅ `docs/todo.md` 作成

### ブランディング

- ✅ アプリ名（FeelShot / App Store: FeelShot ゴルフ）
- ✅ ランチャーアイコン生成（`assets/icon/app_icon.png`）

---

## 次の優先タスク（v1.1 候補）

### 高優先度

- ✅ **アイアン番手選択**  
  - 3〜9 番、`7番アイアン` 形式

- ✅ **ウッド番手選択**
  - 3W / 5W / 7W、`5番ウッド` 形式
- ✅ **ユーティリティ番手選択**
  - 3UT / 4UT / 5UT、`4番ユーティリティ` 形式

- ✅ **アプローチ種類選択**  
  - PW / GW / SW / LW、`SWアプローチ` 形式

- ⬜ **前回の「次回試すこと」を見返す**  
  - 一覧またはホーム上部に直近記録の `nextTry` を強調表示  
  - アプリの核心価値（忘れない）に直結

### 中優先度

- ⬜ **文字数上限のバリデーション**  
  - ✅ 必須3項目: 300文字、メモ: 1000文字

- ⬜ **リリース準備（Android）**  
  - ✅ 耐障害読み込み・保存失敗通知  
  - ✅ Application ID `com.golfrecord.app`  
  - ✅ 署名テンプレ（`docs/RELEASE_ANDROID.md`）  
  - ✅ `docs/release-checklist.md` / `docs/PRIVACY.md`  
  - ⬜ keystore 作成・実機・Play 提出

- ⬜ **番手別飛距離**（記録・平均表示）— 保留

- ⬜ **記録の並び替え**  
  - 日付順 / 更新日順の切替

- ⬜ **テスト拡充**  
  - `RecordStorage` の保存・読み込みテスト  
  - フォームバリデーションのウィジェットテスト
  - ✅ `iron_tag_utils` ユニットテスト
  - ✅ `Record.tryFromJson` ユニットテスト

### 低優先度

- ✅ **アプリ名・アイコン設定**  
  - 表示名「FeelShot」、App Store 名「FeelShot ゴルフ」、カスタムランチャーアイコン（Android / Web / Windows / iOS）

- ⬜ **Git バージョン管理の整備**  
  - 初回コミット、`.gitignore` 確認

- 🔄 **iOS 対応 / App Store 提出**  
  - ✅ Mac 環境・実機 release 起動
  - ✅ Bundle ID `com.golfrecord.app`・Xcode 署名
  - ✅ `docs/RELEASE_IOS.md` / `docs/app-store-listing.md`
  - ⬜ Apple Developer Program 登録
  - ⬜ `flutter build ipa` → App Store Connect 提出

---

## 将来検討（v2 以降）

- ⬜ クラウド同期 / アカウント
- ⬜ 写真・動画添付
- ⬜ スコア記録・統計グラフ
- ⬜ カスタムタグ（ユーザー定義）
- ⬜ 通知（練習前に前回のメモを表示）
- ⬜ 状態管理ライブラリ導入（Riverpod 等）
- ⬜ DB 移行（`sqflite` / `drift`）— 件数増加時
- ⬜ ルーティング整理（`go_router`）
- ⬜ ドライバー等、他タグの詳細選択（番手・距離帯）

---

## 既知の課題・技術的負債

| 項目 | 内容 | 対応方針 |
|------|------|----------|
| 状態管理 | 一覧画面に CRUD・フィルタ・永続化が集中 | 画面増加時にリファクタ |
| タグフィルタ | `iron_tag_utils` でアイアン系タグ・番手に対応 | — |
| ID 生成 | `microsecondsSinceEpoch` 文字列 | 将来 UUID に変更検討 |
| テスト | スモークテストのみ | v1.1 で拡充 |
| エミュレータ入力 | Android 16 でキーボード不具合あり | `hw.keyboard=yes` 設定済み、API 34 AVD も検討 |
| JSON スキーマ | `records_v1` 固定 | スキーマ変更時にマイグレーション設計 |

---

## 開発フロー（参考）

1. `docs/requirements.md` で要件を更新
2. `docs/todo.md` でタスクを追加・優先度付け
3. 1工程ずつ実装 → エミュレータで確認
4. 必要に応じて `docs/architecture.md` を更新
5. 完了したタスクに ✅

---

## 変更履歴

| 日付 | 内容 |
|------|------|
| 2026-05 | 初版作成（MVP v1 完了状態を反映） |
