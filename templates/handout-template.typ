// ボーイスカウト指導者訓練向け Typst 配布資料テンプレート
// A4縦・白黒（モノクロ印刷 / 輪転機 / レーザープリンタ用）

#let black = rgb("#000000")
#let gray-dark = luma(60)
#let gray-light = luma(240)
#let gray-border = luma(180)

/// ワークシート用の記入枠を表示する関数（白黒印刷対応）
/// - height: 記入枠の高さ（デフォルト: 40mm）
/// - label: 枠上部に表示するタイトルラベル（デフォルト: "ワーク記入欄"）
/// - hint: 補足説明や留意点（任意）
#let worksheet-box(
  height: 40mm,
  label: "ワーク記入欄",
  hint: none,
) = {
  v(6pt)
  block(
    width: 100%,
    stroke: 0.8pt + black,
    radius: 0pt,
    fill: rgb("#ffffff"),
    clip: true,
    inset: 0pt,
    [
      #rect(
        width: 100%,
        fill: gray-light,
        inset: (x: 10pt, y: 6pt),
        stroke: (bottom: 0.6pt + black),
      )[
        #text(9pt, weight: "bold", fill: black)[#label]
        #if hint != none [
          #h(8pt)
          #text(8pt, fill: gray-dark)[（#hint）]
        ]
      ]
      #v(height)
    ]
  )
  v(6pt)
}

/// 指導者訓練用配布資料の共通テンプレート関数（白黒印刷対応）
/// - title: セッション名
/// - subtitle: サブタイトル（任意）
/// - course-name: コース名（例: 「第xxx回 ボーイスカウト講習会」）
/// - trainer-name: 担当トレーナー名
/// - date: 実施日
/// - body: 本文コンテンツ
#let scout-handout(
  title: "",
  subtitle: none,
  course-name: "",
  trainer-name: "",
  date: "",
  body,
) = {
  // ページ基本設定
  set page(
    paper: "a4",
    margin: (left: 18mm, right: 18mm, top: 18mm, bottom: 18mm),
    header: align(right)[
      #text(8pt, fill: gray-dark)[#course-name #if date != "" [| #date]]
    ],
    footer: context [
      #set text(8pt, fill: gray-dark)
      #grid(
        columns: (1fr, 1fr),
        align(left)[#title],
        align(right)[#counter(page).display("1 / 1", both: true)]
      )
    ]
  )

  // 日本語フォント設定（白黒テキスト）
  set text(
    font: ("Noto Sans CJK JP", "Hiragino Kaku Gothic ProN", "Hiragino Sans", "BIZ UDPGothic", "Meiryo"),
    size: 10pt,
    fill: black,
    lang: "ja",
  )

  // 段落設定
  set par(
    leading: 0.7em,
    justify: true,
  )

  // 見出しスタイル設定（白黒下線スタイル）
  show heading.where(level: 1): it => block(
    width: 100%,
    stroke: (bottom: 1.2pt + black),
    inset: (bottom: 3pt),
    above: 14pt,
    below: 8pt,
  )[
    #text(fill: black, weight: "bold", size: 12pt)[#it.body]
  ]

  show heading.where(level: 2): it => block(
    above: 10pt,
    below: 6pt,
  )[
    #text(fill: black, weight: "bold", size: 10.5pt)[● #it.body]
  ]

  show heading.where(level: 3): it => block(
    above: 8pt,
    below: 4pt,
  )[
    #text(fill: black, weight: "bold", size: 10pt)[▲ #it.body]
  ]

  // 表スタイル（白黒・グレー網掛け）
  set table(
    stroke: 0.5pt + black,
    fill: (_, row) => if row == 0 { gray-light } else { none },
  )

  // --------------------------------------------------
  // ヘッダー情報部（セッション名 & 受講者記入枠）
  // --------------------------------------------------
  grid(
    columns: (1fr, auto),
    gutter: 14pt,
    align: (left + horizon, right + top),
    [
      #if course-name != "" [
        #text(9pt, fill: gray-dark, weight: "bold")[#course-name]
        #v(2pt)
      ]
      #text(16pt, fill: black, weight: "bold")[#title]
      #if subtitle != none [
        #v(2pt)
        #text(10pt, fill: gray-dark)[#subtitle]
      ]
    ],
    [
      #rect(
        stroke: 0.8pt + black,
        radius: 0pt,
        inset: (x: 10pt, y: 7pt),
        fill: rgb("#ffffff"),
      )[
        #set text(8.5pt)
        #grid(
          columns: (auto, 90pt),
          align: (left + horizon, left + horizon),
          gutter: 5pt,
          [担当トレーナー:], [#if trainer-name != "" { trainer-name } else { line(length: 60pt, stroke: 0.5pt + black) }],
          [班名 / 所属:], [#line(length: 50pt, stroke: 0.5pt + black) 班],
          [受講者氏名:], [#line(length: 75pt, stroke: 0.5pt + black)],
        )
      ]
    ]
  )

  v(8pt)
  line(length: 100%, stroke: 0.8pt + black)
  v(8pt)

  // 本文展開
  body
}
