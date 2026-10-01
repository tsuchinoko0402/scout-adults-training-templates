// ボーイスカウト指導者訓練向け
// セッション要項（セッションの進め方）および 口述要項用 Typst 共通テンプレート

#let border-gray = luma(180)
#let header-bg = luma(235)

// ==============================================================================
// 1. 口述要項テンプレート (session-script)
// ==============================================================================

/// 口述要項の全体レイアウト関数
/// - course-name: コース名（例: "WB研修所 スカウトコース 兵庫第xx期"）
/// - session-id: セッション番号・記号（例: "§5"）
/// - title: セッション名（例: "スカウト運動"）
/// - trainer-name: 担当者名（例: "岡﨑正悟"）
/// - body: 本文（script-table 等）
#let session-script(
  course-name: "",
  session-id: "",
  title: "",
  trainer-name: "",
  body,
) = {
  let session-label = if session-id != "" [ #session-id. #title ] else [ #title ]
  let footer-right = if trainer-name != "" [ #session-label (#trainer-name) ] else [ #session-label ]

  set page(
    paper: "a4",
    margin: (left: 15mm, right: 15mm, top: 18mm, bottom: 18mm),
    header: context {
      if counter(page).get().first() > 1 [
        #set text(size: 8.5pt, fill: luma(60))
        #grid(
          columns: (1fr, auto),
          align(left)[#course-name #session-label],
          align(right)[担当：#trainer-name],
        )
      ]
    },
    footer: context [
      #set text(size: 8.5pt, font: ("Noto Sans CJK JP", "Hiragino Kaku Gothic ProN", "Hiragino Sans", "BIZ UDPGothic"))
      #grid(
        columns: (1fr, 1fr, 1fr),
        align(left)[#course-name],
        align(center)[#counter(page).display("1/1", both: true)],
        align(right)[#footer-right],
      )
    ]
  )

  set text(
    font: ("Noto Sans CJK JP", "Hiragino Kaku Gothic ProN", "Hiragino Sans", "BIZ UDPGothic", "Meiryo"),
    size: 9.5pt,
    fill: rgb("#000000"),
    lang: "ja",
  )

  set par(
    leading: 0.65em,
    justify: true,
  )

  // 1ページ目タイトルヘッダー
  block(width: 100%, inset: (bottom: 4pt))[
    #grid(
      columns: (1fr, auto),
      align: (left, right),
      [#text(9pt)[#course-name #session-label]],
      [#text(9pt)[担当：#trainer-name]]
    )
    #v(2pt)
    #align(center)[
      #text(13pt, weight: "bold")[口述要項]
    ]
  ]

  v(4pt)

  body
}

/// 口述要項用テーブル関数
/// スライドNo, 口述内容, 備考の3列構成テーブルを生成
#let script-table(..rows) = {
  set table(
    stroke: 0.5pt + black,
    fill: (col, row) => if row == 0 { header-bg } else { none },
  )

  table(
    columns: (48pt, 1fr, 75pt),
    align: (col, row) => (
      if row == 0 { center + horizon }
      else if col == 0 { center + top }
      else if col == 2 { left + top }
      else { left + top }
    ),
    table.header(
      [*スライド No*],
      [*口述内容*],
      [*備考*],
    ),
    ..rows
  )
}

/// 口述テーブルの1行を定義するヘルパー関数
#let script-item(slide-no, script, note: "") = (
  [#strong(str(slide-no))],
  [
    #set par(leading: 0.6em)
    #script
  ],
  [
    #set text(size: 8.5pt)
    #note
  ],
)


// ==============================================================================
// 2. セッション要項 / セッションの進め方テンプレート (session-plan)
// ==============================================================================

/// セッション要項（セッションの進め方）の全体レイアウト関数
/// - course-name: コース名（例: "第1156回ボーイスカウト講習会"）
/// - document-type: 文書種別（デフォルト: "セッションの進め方"、"セッション要項" も可）
/// - session-id: セッション番号（例: "§2"）
/// - title: セッションタイトル（例: "愉快なハイキング"）
/// - datetime-info: 実施日時・時間（例: "2026年11月8日(日) 10:45〜13:35 (170分)"）
/// - trainer-name: 担当者名（例: "岡﨑正悟"）
/// - body: 本文
#let session-plan(
  course-name: "",
  document-type: "セッションの進め方",
  session-id: "",
  title: "",
  datetime-info: "",
  trainer-name: "",
  body,
) = {
  let session-label = if session-id != "" [ #session-id. #title ] else [ #title ]
  let footer-right = if trainer-name != "" [ #session-label (#trainer-name) ] else [ #session-label ]

  set page(
    paper: "a4",
    margin: (left: 16mm, right: 16mm, top: 16mm, bottom: 16mm),
    header: align(left)[
      #text(8.5pt, fill: luma(60))[#course-name]
    ],
    footer: context [
      #set text(size: 8.5pt, font: ("Noto Sans CJK JP", "Hiragino Kaku Gothic ProN", "Hiragino Sans", "BIZ UDPGothic"))
      #grid(
        columns: (1fr, 1fr),
        align(center)[#counter(page).display("1")],
        align(right)[#footer-right],
      )
    ]
  )

  set text(
    font: ("Noto Sans CJK JP", "Hiragino Kaku Gothic ProN", "Hiragino Sans", "BIZ UDPGothic", "Meiryo"),
    size: 9.5pt,
    fill: rgb("#000000"),
    lang: "ja",
  )

  set par(
    leading: 0.65em,
    justify: true,
  )

  // レベル1見出し：太線下線
  show heading.where(level: 1): it => block(
    width: 100%,
    stroke: (bottom: 1.2pt + black),
    inset: (bottom: 3pt),
    above: 14pt,
    below: 8pt,
  )[
    #text(weight: "bold", size: 11pt)[#it.body]
  ]

  // レベル2見出し：点線下線
  show heading.where(level: 2): it => block(
    width: 100%,
    stroke: (bottom: (paint: black, thickness: 0.8pt, dash: "dashed")),
    inset: (bottom: 3pt),
    above: 11pt,
    below: 6pt,
  )[
    #text(weight: "bold", size: 10pt)[#it.body]
  ]

  // タイトル部
  v(2pt)
  text(18pt, weight: "bold")[#document-type]
  v(1pt)
  line(length: 100%, stroke: 1.8pt + black)
  v(6pt)

  // セッション名（枠囲み）
  rect(
    stroke: 1pt + black,
    inset: (x: 10pt, y: 7pt),
    radius: 0pt,
  )[
    #text(12pt, weight: "bold")[#if session-id != "" [#session-id ] #title]
  ]

  v(2pt)

  // 日時と担当者
  grid(
    columns: (1fr, auto),
    align: (left + horizon, right + horizon),
    [#if datetime-info != "" [#text(9.5pt)[#datetime-info]]],
    [#if trainer-name != "" [#text(9.5pt)[担当：#trainer-name]]],
  )

  v(8pt)

  body
}

/// タイムテーブル作成用テーブル関数
#let timeline-table(..rows) = {
  set table(
    stroke: 0.5pt + black,
    fill: (col, row) => if row == 0 { header-bg } else { none },
  )

  table(
    columns: (58pt, 44pt, 68pt, 50pt, 1fr),
    align: (col, row) => (
      if row == 0 { center + horizon }
      else if col == 0 { center + horizon }
      else if col == 1 { center + horizon }
      else if col == 2 { left + top }
      else if col == 3 { center + top }
      else { left + top }
    ),
    table.header(
      [*時間配分*],
      [*所要時間*],
      [*展開ステップ*],
      [*参加者のマインド*],
      [*指導者・スタッフの動き / 演出・留意点*],
    ),
    ..rows
  )
}
