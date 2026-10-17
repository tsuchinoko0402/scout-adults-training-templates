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
  v(4pt)
  block(
    width: 100%,
    breakable: false,
    stroke: 0.8pt + black,
    radius: 0pt,
    fill: rgb("#ffffff"),
    clip: true,
    inset: 0pt,
    [
      #rect(
        width: 100%,
        fill: gray-light,
        inset: (x: 8pt, y: 5pt),
        stroke: (bottom: 0.6pt + black),
      )[
        #text(8.5pt, weight: "bold", fill: black)[#label]
        #if hint != none [
          #h(6pt)
          #text(7.5pt, fill: gray-dark)[（#hint）]
        ]
      ]
      #v(height)
    ]
  )
  v(4pt)
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
  trainer-label: "担当講師:",
  date: "",
  body,
) = {
  // ページ基本設定
  set page(
    paper: "a4",
    margin: (left: 15mm, right: 15mm, top: 14mm, bottom: 14mm),
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
    size: 9pt,
    fill: black,
    lang: "ja",
  )

  // 段落設定
  set par(
    leading: 0.58em,
    justify: true,
  )

  // 見出しスタイル設定（白黒下線スタイル）
  show heading.where(level: 1): it => block(
    width: 100%,
    stroke: (bottom: 1.2pt + black),
    inset: (bottom: 2pt),
    above: 9pt,
    below: 5pt,
  )[
    #text(fill: black, weight: "bold", size: 10.5pt)[#it.body]
  ]

  show heading.where(level: 2): it => block(
    above: 7pt,
    below: 3pt,
  )[
    #text(fill: black, weight: "bold", size: 9.5pt)[● #it.body]
  ]

  show heading.where(level: 3): it => block(
    above: 5pt,
    below: 2pt,
  )[
    #text(fill: black, weight: "bold", size: 9pt)[▲ #it.body]
  ]

  // 表スタイル（白黒・グレー網掛け）
  set table(
    stroke: 0.5pt + black,
    inset: (x: 6pt, y: 4.5pt),
    fill: (_, row) => if row == 0 { gray-light } else { none },
  )

  // --------------------------------------------------
  // ヘッダー情報部（セッション名 & 受講者記入枠）
  // --------------------------------------------------
  grid(
    columns: (1fr, auto),
    gutter: 10pt,
    align: (left + horizon, right + top),
    [
      #if course-name != "" [
        #text(8.5pt, fill: gray-dark, weight: "bold")[#course-name]
        #v(1pt)
      ]
      #text(15pt, fill: black, weight: "bold")[#title]
      #if subtitle != none [
        #v(1pt)
        #text(9pt, fill: gray-dark)[#subtitle]
      ]
    ],
    [
      #rect(
        stroke: 0.8pt + black,
        radius: 0pt,
        inset: (x: 8pt, y: 5pt),
        fill: rgb("#ffffff"),
      )[
        #set text(8pt)
        #grid(
          columns: (auto, auto),
          align: (left + horizon, left + horizon),
          gutter: 4.5pt,
          [#trainer-label], [#if trainer-name != "" { trainer-name } else { line(length: 110pt, stroke: 0.5pt + black) }],
          [班名 / 所属:], [#box[#line(length: 115pt, stroke: 0.5pt + black)] 班],
          [受講者氏名:], [#line(length: 135pt, stroke: 0.5pt + black)],
        )
      ]
    ]
  )

  v(5pt)
  line(length: 100%, stroke: 0.8pt + black)
  v(8pt)

  // 本文展開
  body
}
