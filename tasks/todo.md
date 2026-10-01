# Implementation Plan - Scout Trainer Template Repository

ボーイスカウト指導者訓練（講習会、研修所、実修所等）向け、Marp（スライド）と Typst（配布資料・セッション要項・口述要項）を組み合わせた成果物管理テンプレートリポジトリの構築。

## User Review Required
> [!IMPORTANT]
> - 日本連盟の公式素材・商標を安全に扱うため、公開リポジトリ本体への公式素材同梱は行わず、各自が「PRツールダウンロードセンター」から適法に入手して `assets/` に配置する構成を徹底しています。
> - ユーザーによる `README.md` の改訂ニュアンスを100%尊重しつつ、公式PRツールダウンロードセンターへの案内リンクを追加しました。
> - 作成完了後、Gitコミットの承認を依頼します。

## 構築タスク進捗状況

- [x] **1. Git & Editor Configuration**
  - [x] `.gitignore` (ビルド生成物 `*.pdf`, `*.html`、OS一時ファイル、キャッシュ等を除外)
  - [x] `LICENSE` (MIT License)
  - [x] `.vscode/settings.json` (Marpカスタムテーマ登録、Typstファイル関連付け)

- [x] **2. Assets & Copyright Guide**
  - [x] `assets/dummy-bg.svg` (グリーン基調のスカウト風背景SVG)
  - [x] `assets/README.md` (PRツールダウンロードセンター案内、配置手順、著作権ガイドライン)

- [x] **3. Templates (Core System)**
  - [x] `templates/marp-scout-theme.css`
    - `@theme scout`, 16:9, スカウトグリーン `#005940`
    - 背景色付きヘッダー帯（スカウトグリーン）＆フッター帯（淡緑グレー）
    - タイトル（`h1`）一番上固定＆コンテンツ上揃えレイアウト（`justify-content: flex-start`）
    - 表紙の「日時・場所・担当者」メタボックス（`.lead-meta`）
    - leadスライドのstrong白文字対応, 部門色変数, `lead-*`, `divider`, `.columns`, `.card` 等
  - [x] `templates/handout-template.typ` (白黒印刷・輪転機対応、A4縦、受講者氏名下線枠、`worksheet-box` 白黒)
  - [x] `templates/session-doc-template.typ`
    - `session-plan` 関数（コース名ヘッダー、タイトル枠、太線下線・点線下線見出し、フッター）
    - `timeline-table` 関数（進行展開表）
    - `session-script` 関数（コース名ヘッダー、タイトル、中央ページ番号 `1/1`、右下セッション名フッター）
    - `script-table` & `script-item` 関数（スライドNo、口述内容、備考の3列テーブル）

- [x] **4. Sample Session (`sessions/00-sample-session/`)**
  - [x] `slides.md` / `slides.pdf` / `slides.html`: スライド1〜6のダミープレースホルダー（表紙日時・場所・担当、ヘッダー/フッター帯、上揃え）
  - [x] `script.md` / `script.typ` / `script.pdf`: スライド1〜6と1対1で対応した3列テーブルのダミー口述要項
  - [x] `plan.md` / `plan.typ` / `plan.pdf`: セッション要項（実物準拠のレイアウト・見出し下線・タイムテーブルのダミー原稿）
  - [x] `handout.md` / `handout.typ` / `handout.pdf`: 白黒仕様のA4配布資料（Markdown版 ＆ Typst版）

- [x] **5. Build Automation & CI**
  - [x] `Makefile` (`slides`, `slides-pdf`, `slides-html`, `handout`, `plan`, `script`, `docs`, `all`, `preview`, `new`, `clean`, `help` ターゲット、`--root .` 対応)
  - [x] `.github/workflows/build-check.yml` (GitHub Actions による全PDF & HTMLビルド疎通テスト)

- [x] **6. Repository Documentation**
  - [x] `README.md` (ユーザー改訂反映、公式PRツールリンク、スライド・白黒ハンドアウト・upstream同期ガイド)

## Verification
- [x] 公式 PRツールダウンロードセンターの規約・ガイドライン確認完了
- [x] `README.md` および `assets/README.md` への公式素材ダウンロード先リンク反映完了
- [x] Gitステータス確認・全構成ファイルの整合性検証完了
