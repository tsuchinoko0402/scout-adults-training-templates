# scout-trainer-template

ボーイスカウトの指導者訓練（講習会、研修所、実修所など）で活用できる、**Marp（投影スライド）** と **Typst（配布資料・要項・口述原稿）** を組み合わせた成果物管理テンプレートリポジトリです。

![GitHub Actions CI](https://github.com/tsuchinoko0402/scout-adults-training-templates/actions/workflows/build-check.yml/badge.svg)
![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)

---

## 📌 本テンプレートの特徴

1. **指導者訓練に必要な4大成果物を網羅（Markdown ＆ PDF/HTML）**
   1つのセッションにつき、以下の4点を同一ディレクトリ内で完結管理できます。
   * **セッション要項** (`plan.md` / `plan.typ`): 進行タイムライン・目標・留意点
   * **口述要項** (`script.md` / `script.typ`): **スライドNo・口述内容・備考の3列テーブル**（ページ番号 `1/6` 等）
   * **投影スライド** (`slides.md`): Marp による 16:9 ボーイスカウト風カスタムテーマ（**PDF & HTML 両対応**）
   * **受講者配布資料** (`handout.md` / `handout.typ`): Typst による **完全白黒（モノクロ印刷・輪転機対応）** A4 ワークシート

2. **スカウト指導者向け専用デザインシステム**
   * 日本連盟のスカウトグリーン（`#005940`）を基調とした Marp テーマ。
   * 部門別カラー（BVS/CS/BS/VS/RS）への切り替え、カードUI、2〜3カラム分割レイアウトを完備。

3. **Makefile と `session.toml` による提出用ファイル名の自動生成（`dist/`）**
   * `session.toml` にセッション名・回次・枝番を設定するだけで、Google Drive 共有や主任講師提出用の正式ファイル名（例：`02-11_§2. 愉快なハイキング_口述要項_1156回BS講習会.pdf`）が `dist/` フォルダへ自動出力されます。
   * 同時に Typst ドキュメント（要項・口述要項・配布資料）のヘッダー情報にも自動反映されるため、二重管理が不要です。

---

## 📁 ディレクトリ構成（パターンA：セッションテーマ軸）

```text
scout-trainer-template/
├── .github/
│   └── workflows/
│       └── build-check.yml       # push/PR時に全成果物のビルド疎通を確認するCI
├── .vscode/
│   └── settings.json             # Marp for VS Code のカスタムテーマ設定
├── assets/
│   ├── README.md                 # 公式画像素材のダウンロード案内と配置ガイド
│   └── dummy-bg.svg              # 公式画像未配置時でも動作確認できるダミー背景
├── scripts/
│   └── session_tool.py           # session.toml 解析・dist/ 正式名出力・プリセット初期化
├── templates/
│   ├── marp-scout-theme.css      # Marp用ボーイスカウト風カスタムテーマ（帯付き・上揃え）
│   ├── handout-template.typ      # Typst用A4白黒受講者配布資料共通テンプレート
│   └── session-doc-template.typ  # Typst用A4セッション要項・口述要項共通テンプレート
├── sessions/
│   ├── 00-sample-session/        # セッション雛形（汎用ダミープレースホルダー）
│   └── 01-BS-Koshukai/           # ボーイスカウト講習会（テーマ軸整理）
│       ├── 01-world-scouting/    # §1「世界に広がるボーイスカウト」
│       ├── 02-pleasant-hiking/   # §2「愉快なハイキング」
│       │   └── 2026-11-08-1156th-hyogo/
│       │       ├── session.toml          # ★ セッション名・回次・枝番の設定ファイル
│       │       ├── slides.md             # 投影スライド（Marp）
│       │       ├── plan.md / plan.typ    # セッションの進め方（要項）
│       │       ├── script.md / script.typ# 口述要項
│       │       ├── safety-plan.typ       # 安全計画書（任意）
│       │       └── dist/                 # ★ 自動生成される提出・Google Drive共有用フォルダ
│       │           ├── 02-00_§2. 愉快なハイキング_スライド資料_1156回BS講習会.pdf
│       │           ├── 02-00_§2. 愉快なハイキング_スライド資料_1156回BS講習会.html
│       │           ├── 02-01_§2. 愉快なハイキング_セッションの進め方_1156回BS講習会.pdf
│       │           ├── 02-11_§2. 愉快なハイキング_口述要項_1156回BS講習会.pdf
│       │           └── 02-12_§2. 愉快なハイキング_安全計画書_1156回BS講習会.pdf
│       ├── 03-what-is-scouting/  # §3「スカウティングって何だろう」
│       ├── 04-supporting-people/ # §4「スカウティングを支える人たち」
│       └── 05-future-of-youth/   # §5「青少年の未来のために」
├── Makefile                      # ビルド・プレビュー自動化コマンド
├── .gitignore
├── LICENSE                       # MIT License
└── README.md                     # 本ドキュメント
```

---

## 🚀 クイックスタート

### 1. テンプレートからリポジトリを作成

1. 本リポジトリ右上の **[Use this template]** ボタンをクリックし、**[Create a new repository]** を選択します。
2. リポジトリの公開範囲を **Private（非公開）** に設定することを推奨します。
   > [!IMPORTANT]
   > 実際の指導者訓練で作成する講話内容や受講者情報、連盟公式資料の引用を含む場合は、著作権および個人情報保護の観点から必ず **Private リポジトリ** で運用してください。

### 2. 必要ツールのインストール

以下のツールをローカル環境にインストールします。

#### ① Node.js & Marp CLI
スライドのビルド・PDF/HTML出力に使用します。リポジトリ直下で `npm install` を実行することで、必要な Marp CLI がローカルにセットアップされます。
```bash
npm install
```
※ グローバルに導入したい場合は `npm install -g @marp-team/marp-cli` を実行してください。どちらの場合でも `make` コマンドが自動検出して実行します。

#### ② Typst
配布資料・要項・口述原稿の組版に使用します。
```bash
# macOS (Homebrew)
brew install typst

# Windows (winget または Scoop)
winget install --id Typst.Typst

# Linux (Cargo)
cargo install --locked typst-cli
```

#### ③ VS Code 推奨拡張機能（任意・推奨）
* [Marp for VS Code](https://marketplace.visualstudio.com/items?itemName=marp-team.marp-vscode)
* [Typst LSP / Tinymist Typst](https://marketplace.visualstudio.com/items?itemName=myriad-dreamit.tinymist)

---

## 🛠️ コマンド一覧（Makefile）

| コマンド | 説明 |
| :--- | :--- |
| `make all SESSION=<dir>` | 全成果物を一括ビルドし、**`dist/` に正式ファイル名で整理** |
| `make docs SESSION=<dir>` | 提出書類（要項・口述・配布資料・安全計画書）を一括PDF出力し `dist/` に整理 |
| `make dist SESSION=<dir>` | ビルド済み成果物を `session.toml` に基づき `dist/` へ正式名コピー |
| `make slides SESSION=<dir>` | 指定セッションのスライドを **PDF と HTML の両方で出力** |
| `make slides-html SESSION=<dir>` | 指定セッションのスライドを HTML のみ出力（ブラウザ即上映用） |
| `make slides-pdf SESSION=<dir>` | 指定セッションのスライドを PDF のみ出力 |
| `make handout SESSION=<dir>` | 指定セッションの受講者配布資料を PDF 出力（存在しない場合は自動スキップ） |
| `make plan SESSION=<dir>` | 指定セッションのセッション要項を PDF 出力 |
| `make script SESSION=<dir>` | 指定セッションの口述要項を PDF 出力 |
| `make safety-plan SESSION=<dir>` | 指定セッションの安全計画書を PDF 出力（存在する場合のみ） |
| `make preview SESSION=<dir>` | 発表者ツール付き Marp プレビューサーバーを起動 |
| `make new SESSION=<dir> [PRESET=bs1..bs5]` | 新規セッションを作成（BS講習会プリセット・パスから日付と回次を自動設定） |
| `make assets` | 日本連盟公式PRツール素材（壁紙・ロゴ）を `assets/` へ自動ダウンロード |
| `make clean-assets` | ダウンロードした公式PRツール素材を削除（初期ダミー状態へ復元） |
| `make clean` | 生成された PDF / HTML / `dist/` を一括削除 |

### 💡 BS講習会プリセットを使った新規セッション作成例

フォルダパスに `01-world-scouting`〜`05-future-of-youth` や日付・回次（`2026-11-08-1156th-hyogo` 等）を含めて `make new` を実行すると、該当セッションのタイトル・所要時間・回次・日付が自動的にセットされた `session.toml` と `slides.md` が生成されます。

```bash
# §3「スカウティングって何だろう」を新規作成（パスから §3・日付・1156回を自動判定）
make new SESSION=01-BS-Koshukai/03-what-is-scouting/2026-11-08-1156th-hyogo TRAINER="岡﨑 正悟"

# 明示的にプリセット（bs1〜bs5）や講習会名を指定して作成することも可能
make new SESSION=01-BS-Koshukai/custom-folder PRESET=bs2 EVENT="1156回BS講習会"
```
※ カリキュラム改定等でセッション名や枝番が変わった場合も、生成された `session.toml` を書き換えるだけで自在に変更できます。

---

## 🎨 スライドテーマ（Marp）の活用法

`templates/marp-scout-theme.css` は、講習会・WB研修所のスライド上映に特化した設計です。
日本連盟公式 PR ツール素材（PC壁紙・タグライン）と連動する設計になっており、**画像素材を用意・配置するだけで、公式感あふれる美しいデザインのスライドを自動生成**できます。

> [!TIP]
> **素材未配置でも安心（グレースフル・フォールバック）**
> 公式素材が配置されていない場合でも、CSS のフォールバック色およびテンプレート同梱の `assets/dummy-bg.svg` により、レイアウト崩れやリンク切れエラーを起こさず独立して成立します。

---

### 1. 公式画像素材の入手と配置方法

以下のコマンドを実行すると、日本連盟公式 PR ツールから壁紙（全5部門）およびタグラインが一括ダウンロードされます：

```bash
# 公式素材の一括ダウンロード
make assets

# 公式素材の削除（初期のクリーン・ダミー状態へ戻す）
make clean-assets
```

手動で配置する場合は、以下のファイル名で `assets/` ディレクトリに保存してください：

| 素材種別 | 推奨ファイル名 | 取得元（公式PRツール） | スライドでの反映箇所 |
| :--- | :--- | :--- | :--- |
| **PC壁紙（共通・ボーイ）** | `assets/PCWall_BS.png` | PC壁紙（1920x1080） | 表紙背景 (`lead`) および 本文フッター背景帯 |
| **PC壁紙（ビーバー）** | `assets/PCWall_BVS.png` | PC壁紙（1920x1080） | ビーバー部門表紙 (`lead-bvs`) および フッター帯 |
| **PC壁紙（カブ）** | `assets/PCWall_CS.png` | PC壁紙（1920x1080） | カブ部門表紙 (`lead-cs`) および フッター帯 |
| **PC壁紙（ベンチャー）** | `assets/PCWall_VS.png` | PC壁紙（1920x1080） | ベンチャー部門表紙 (`lead-vs`) および フッター帯 |
| **PC壁紙（ローバー）** | `assets/PCWall_RS.png` | PC壁紙（1920x1080） | ローバー部門表紙 (`lead-rs`) および フッター帯 |
| **1行タグライン（白抜き）** | `assets/tagline_1line.png` | タグライン（横長1行） | 本文フッター右下 |

※ `.gitignore` により公式画像ファイルは Git 追跡から自動除外されるため、GitHub へ誤コミットされる心配はありません。

---

### 2. Markdown（`slides.md`）での指定方法

#### ① ヘッダー帯・フッター帯の設定（フロントマター）
スライド全体の YAML フロントマターでヘッダー・フッターを設定します。
```yaml
---
marp: true
theme: scout
paginate: true
header: '<span>20xx年度 指導者研修コース</span><span>§1. セッション名（担当：指導 太郎）</span>'
footer: '<span>20xx年〇月〇日</span><span><img src="../../assets/tagline_1line.png" class="footer-tagline" alt="" onerror="this.style.display=\x27none\x27" /></span>'
---
```
* **ヘッダー帯（スカウトグリーン）**: スライド最上端に固定。左上に「研修名」、右上に「セッション名（担当者名）」が白抜きで表示されます。
* **フッター帯（壁紙ウェーブ背景）**: スライド最下端に固定。
  * **左下**: 「年月日」
  * **真ん中**: 「ページ番号」（自動採番・中央揃え）
  * **右下**: 公式タグライン「人と地球によりよい未来を」（白抜き表示）
  * ※ `onerror="this.style.display='none'"` を記述しておくことで、素材未配置時でもリンク切れアイコンを出さずに自然に非表示となります。
* **タイトル固定・上揃え**: スライドのタイトル（`h1`）は最上部に固定され、コンテンツはすべて上揃え（Top-aligned）で配置されます。

#### ② 表紙スライド（リードスライド）の指定
スライド冒頭に `_class: lead`（または部門別クラス）を指定します。
```markdown
<!--
_class: lead
_paginate: false
-->

#### 20xx年度 指導者研修コース

# セッション名（サンプル）

## サブタイトルをここに記載します

<div class="lead-meta">

**日時**: 20xx年〇月〇日(〇) 00:00〜00:45  
**場所**: 〇〇県立野外活動センター 第1研修室  
**担当**: 指導 太郎（〇〇連盟 〇〇地区）

</div>
```
* 公式壁紙が存在する場合、左下の「ボーイスカウト」ロゴや右上のタグラインと干渉しない中央領域にセッション情報が整然とレイアウトされます。
* 部門別スライドにしたい場合は、`_class: lead-bvs`（ビーバー）、`_class: lead-cs`（カブ）、`_class: lead-vs`（ベンチャー）、`_class: lead-rs`（ローバー）を指定してください。

#### ③ 本文スライドでの部門別フッター帯の切り替え
本文スライドでも部門別の壁紙ウェーブ背景を適用したい場合は、該当ページに部門クラスを指定します：
```markdown
<!-- _class: bvs -->
# ビーバー隊の集会計画
（水色のビーバー壁紙ウェーブがフッターに適用されます）
```

#### ④ カラム・カードレイアウト
```markdown
<div class="columns-3">
  <div class="card">
    <div class="card-title">① 自治の尊重</div>
    <p>スカウトに任せ、失敗から学ばせる。</p>
  </div>
  <div class="card">
    <div class="card-title">② 黒子の役割</div>
    <p>指示ではなく問いかけで気づきを促す。</p>
  </div>
  <div class="card">
    <div class="card-title">③ 安全の担保</div>
    <p>セーフ・フロム・ハームの徹底。</p>
  </div>
</div>
```

---

## 📄 配布資料・要項・口述原稿（Typst）の活用法

### ① セッション要項（セッションの進め方：`plan.typ`）
実線下線（レベル1見出し）、点線下線（工夫見出し）、タイムテーブル表を備えた実務準拠のレイアウトです。
```typst
#import "../../templates/session-doc-template.typ": session-plan, timeline-table

#show: session-plan.with(
  course-name: "20xx年度 指導者研修コース",
  document-type: "セッションの進め方",
  session-id: "§1",
  title: "セッション名（サンプル）",
  datetime-info: "20xx年〇月〇日(〇) 00:00〜00:45 (45分)",
  trainer-name: "指導 太郎",
)

= 指導上のねらい
1. 〇〇に関する基本的な知識を理解させる。

= 実施にあたっての工夫
== 工夫①：【マインドセットの転換】ここに工夫のタイトルを記載
- *ねらい*: 工夫の目的を記載。

= タイムテーブル
#timeline-table(
  [00:00 〜\ 00:05], [5分], [1. 導入], [大人の受講者], [ねらいの提示],
)
```

### ② 口述要項（トークスクリプト：`script.typ`）
スライドNo・口述内容・備考の3列テーブル。フッター中央に総ページ数付きページ番号（`1/6` 等）が自動出力されます。
```typst
#import "../../templates/session-doc-template.typ": session-script, script-table, script-item

#show: session-script.with(
  course-name: "20xx年度 指導者研修コース",
  session-id: "§1",
  title: "セッション名（サンプル）",
  trainer-name: "指導 太郎",
)

#script-table(
  ..script-item(
    1,
    [それではセッションを始めていきます。担当の〇〇です。],
    note: [開始・礼\ スライド1投影],
  ),
  ..script-item(
    2,
    [本セッションの目的を確認します。……],
    note: [スライド2投影],
  ),
)
```

### ③ 受講者配布資料（`handout.typ`）
輪転機やモノクロレーザープリンターでの大量印刷に配慮した**完全白黒仕様**です。
```typst
#import "../../templates/handout-template.typ": scout-handout, worksheet-box

#show: scout-handout.with(
  title: "セッション名（サンプル）",
  subtitle: "サブタイトルをここに記載します",
  course-name: "20xx年度 指導者研修コース",
  trainer-name: "指導 太郎",
  date: "20xx年〇月〇日",
)

= 1. セッションのねらい
本文を記載します。

// 受講者記入用の白黒ワークボックス
#worksheet-box(
  height: 35mm,
  label: "ワーク 1：気づいたことの記入欄",
  hint: "キーワードを3つ書き出してください",
)
```

---

## 🔄 テンプレート自体の更新（デザイン改訂）への追従方法

本リポジトリ（親テンプレート）側でテーマCSSやTypstテンプレートに関数の追加やデザイン改善が行われた場合、**自分が作成した各セッションの内容（`sessions/`）を一切壊すことなく、テンプレート機構のみを安全に取り込む（同期する）** ことができます。

### 推奨：Git リモート（upstream）から共通設定のみを取り込む

ご自身のクローンしたリポジトリで以下の手順を実行します。

```bash
# 1. 初回のみ：親テンプレートリポジトリを "upstream" として登録
git remote add upstream https://github.com/tsuchinoko0402/scout-adults-training-templates.git

# 2. 親テンプレートの最新情報を取得
git fetch upstream

# 3. templates/ や scripts/、Makefile などの共通仕組みのみをピンポイントで取り込む
git checkout upstream/main -- templates/ scripts/ Makefile .github/

# 4. 変更内容を確認してコミット
git status
git commit -m "chore: 親テンプレートの最新デザイン・ビルド設定を取り込み"
```

> [!TIP]
> 上記のコマンド（`git checkout upstream/main -- templates/ ...`）を使用すると、`sessions/` 配下の自分が執筆した原稿（セッション要項・スライド・配布資料等）との競合（コンフリクト）が原理的に発生せず、CSS や Typst の共通定義・`Makefile` のみ安全に最新化されます。

### 手動での更新方法（GitHub Desktop または Web の場合）
1. 親テンプレートリポジトリの `templates/` フォルダをダウンロードします。
2. 自身のリポジトリの `templates/` フォルダに上書き保存し、コミットします。

---

## ⚠️ 著作権・商標に関する免責事項

1. **非公式テンプレート**: 本リポジトリは有志の指導者によって作成された非公式のオープンソーステンプレートであり、公益財団法人ボーイスカウト日本連盟の公式発行物・認証リポジトリではありません。
2. **公式素材の不同梱**: 連盟章、各部門記章、公式マニュアル等の公式画像・テキストは含まれていません。
3. **各自の利用責任**: 日本連盟公式の「[PRツールダウンロードセンター](https://www.scout.or.jp/member/download/pr-tool)」等からダウンロードした素材（壁紙やロゴ等）を配置して利用する場合は、日本連盟のガイドラインに従い、個人の責任においてご利用ください。

---

## 📄 ライセンス

本テンプレートのコード・CSS・構成ファイルは [MIT License](LICENSE) のもとで公開されています。商用・非商用問わず、各団・地区・連盟での指導者訓練に自由にご活用いただけます。
