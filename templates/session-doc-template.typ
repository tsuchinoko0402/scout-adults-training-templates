// ボーイスカウト指導者訓練向け
// セッション要項（セッションの進め方）、口述要項、および各種付属計画書用 Typst 共通テンプレート

#let border-gray = luma(180)
#let header-bg = luma(235)

// 標準フォント設定（sys.inputs による外部注入にも対応）
#let default-doc-font-sans = if "font-sans" in sys.inputs {
  (sys.inputs.font-sans,)
} else {
  ("Hiragino Kaku Gothic ProN", "Hiragino Sans")
}

#let default-doc-font-serif = if "font-serif" in sys.inputs {
  (sys.inputs.font-serif,)
} else {
  ("Hiragino Mincho ProN", "YuMincho")
}

// ==============================================================================
// 共通内部ヘルパー関数
// ==============================================================================

/// 統一ヘッダー・フッターをページ設定に適用する内部ヘルパー
#let _apply-session-page-style(
  course-name: "",
  session-label: "",
  date: "",
  trainer-name: "",
) = (
  paper: "a4",
  margin: (left: 15mm, right: 15mm, top: 15mm, bottom: 15mm),
  header: context {
    // 2ページ目以降に上部ヘッダーを表示（1ページ目は本文タイトルと重複するため非表示）
    if counter(page).get().first() > 1 [
      #set text(size: 8pt, fill: luma(80), font: default-doc-font-sans)
      #grid(
        columns: (1fr, auto),
        align(left)[#course-name],
        align(right)[#date],
      )
      #v(-3pt)
      #line(length: 100%, stroke: 0.4pt + border-gray)
    ]
  },
  footer: context [
    #line(length: 100%, stroke: 0.4pt + border-gray)
    #v(-2pt)
    #set text(size: 8pt, fill: luma(60), font: default-doc-font-sans)
    #grid(
      columns: (1.2fr, 1fr, 1.2fr),
      align(left)[#session-label],
      align(center)[#counter(page).display("1 / 1", both: true)],
      align(right)[#if trainer-name != "" [担当：#trainer-name]],
    )
  ],
)

// ==============================================================================
// 1. 口述要項テンプレート (session-script)
// ==============================================================================

/// 口述要項の全体レイアウト関数
/// - course-name: コース名（例: "第1156回ボーイスカウト講習会"）
/// - session-id: セッション番号・記号（例: "§1"）
/// - title: セッション名（例: "世界に広がるボーイスカウト"）
/// - date: 実施日（例: "2026年11月8日"）
/// - trainer-name: 担当者氏名（例: "岡﨑 正悟"）
/// - body: 本文（script-table 等）
#let session-script(
  course-name: "",
  session-id: "",
  title: "",
  date: "",
  trainer-name: "",
  body,
) = {
  let session-label = if session-id != "" [#session-id. #title] else [#title]

  set page(.._apply-session-page-style(
    course-name: course-name,
    session-label: session-label,
    date: date,
    trainer-name: trainer-name,
  ))

  set text(
    font: default-doc-font-sans,
    size: 9pt,
    fill: rgb("#000000"),
    lang: "ja",
  )

  set par(
    leading: 0.58em,
    justify: true,
  )

  // 1ページ目タイトルヘッダー
  block(width: 100%, inset: (bottom: 2pt))[
    #grid(
      columns: (1fr, auto),
      align: (left, right),
      [#text(8.5pt, fill: luma(80))[#course-name #session-label]],
      [#text(8.5pt, fill: luma(80))[#date]]
    )
    #v(2pt)
    #align(center)[
      #text(13pt, weight: "bold")[口述要項]
    ]
  ]

  v(2pt)

  body
}

/// 口述要項用テーブル関数
/// スライドNo, 口述内容, 備考の3列構成テーブルを生成
#let script-table(..rows) = {
  set table(
    stroke: 0.5pt + black,
    inset: (x: 6pt, y: 4.5pt),
    fill: (col, row) => if row == 0 { header-bg } else { none },
  )

  table(
    columns: (52pt, 1fr, 76pt),
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

/// 口述テーブルの1行を定義するヘルパー関数（ページ跨ぎでの行途中分割を防止）
#let script-item(slide-no, script, note: "") = (
  table.cell(breakable: false)[#strong(str(slide-no))],
  table.cell(breakable: false)[
    #set par(leading: 0.52em)
    #script
  ],
  table.cell(breakable: false)[
    #set text(size: 8pt)
    #set par(leading: 0.5em)
    #note
  ],
)

// ==============================================================================
// 2. セッション要項 / セッションの進め方テンプレート (session-plan)
// ==============================================================================

/// セッション要項（セッションの進め方）の全体レイアウト関数
/// - course-name: コース名（例: "第1156回ボーイスカウト講習会"）
/// - document-type: 文書種別（デフォルト: "セッションの進め方"）
/// - session-id: セッション番号（例: "§1"）
/// - title: セッションタイトル（例: "世界に広がるボーイスカウト"）
/// - date: 実施日（例: "2026年11月8日"）
/// - datetime-info: 実施日時・時間（例: "2026年11月8日(日) 10:00〜10:40 (40分)"）
/// - role-name: 担当班・役務（例: "きつつき班"）※大要ヘッダー部にのみ表示
/// - trainer-name: 担当者氏名（例: "岡﨑 正悟"）※フッターおよび大要に表示
/// - body: 本文
#let session-plan(
  course-name: "",
  document-type: "セッションの進め方",
  session-id: "",
  title: "",
  date: "",
  datetime-info: "",
  role-name: "",
  trainer-name: "",
  body,
) = {
  let session-label = if session-id != "" [#session-id. #title] else [#title]

  set page(.._apply-session-page-style(
    course-name: course-name,
    session-label: session-label,
    date: date,
    trainer-name: trainer-name,
  ))

  set text(
    font: default-doc-font-sans,
    size: 9.5pt,
    fill: rgb("#000000"),
    lang: "ja",
  )

  set par(
    leading: 0.6em,
    justify: true,
  )

  // レベル1見出し：太線下線
  show heading.where(level: 1): it => block(
    width: 100%,
    stroke: (bottom: 1.2pt + black),
    inset: (bottom: 2.5pt),
    above: 12pt,
    below: 6pt,
  )[
    #text(weight: "bold", size: 10.5pt)[#it.body]
  ]

  // レベル2見出し：点線下線
  show heading.where(level: 2): it => block(
    width: 100%,
    stroke: (bottom: (paint: black, thickness: 0.8pt, dash: "dashed")),
    inset: (bottom: 2.5pt),
    above: 9pt,
    below: 5pt,
  )[
    #text(weight: "bold", size: 9.5pt)[#it.body]
  ]

  // タイトル部（文字のすぐ下に罫線を引き締め、離れすぎを解消）
  block(
    width: 100%,
    stroke: (bottom: 1.5pt + black),
    inset: (bottom: 2.5pt),
    above: 0pt,
    below: 5pt,
  )[
    #text(16pt, weight: "bold")[#document-type]
  ]

  // セッション名（枠囲み）
  rect(
    stroke: 1pt + black,
    inset: (x: 10pt, y: 6pt),
    width: 100%,
    radius: 0pt,
  )[
    #text(12pt, weight: "bold")[#if session-id != "" [#session-id ] #title]
  ]

  v(2pt)

  // 日時と担当者（1ページ目大要部）
  grid(
    columns: (1fr, auto),
    align: (left + horizon, right + horizon),
    [#if datetime-info != "" [#text(9pt)[#datetime-info]]],
    [#text(9pt)[
      #if role-name != "" [担当：#role-name#h(8pt)氏名：#trainer-name] else if trainer-name != "" [担当：#trainer-name]
    ]],
  )

  v(6pt)

  body
}

/// セッション展開表作成用テーブル関数
/// - columns: 列数（3: 新標準[時間(所要) / 内容 / 準備品]、4: [時間 / 所要 / ステップ / 内容]、5: [時間 / 所要 / ステップ / マインド / 内容]）
/// - has-mind: 旧互換用（true: 5列、false: 4列）
#let timeline-table(
  columns: auto,
  has-mind: auto,
  ..rows
) = {
  set table(
    stroke: 0.5pt + black,
    fill: (col, row) => if row == 0 { header-bg } else { none },
  )

  let unbreakable-rows = rows.pos().map(cell => table.cell(breakable: false)[#cell])

  let col-mode = if columns != auto {
    columns
  } else if has-mind == true {
    5
  } else if has-mind == false {
    4
  } else {
    3
  }

  if col-mode == 3 {
    table(
      columns: (68pt, 1fr, 110pt),
      align: (col, row) => (
        if row == 0 { center + horizon }
        else if col == 0 { center + top }
        else if col == 2 { left + top }
        else { left + top }
      ),
      table.header(
        [*時間（所要）*],
        [*内容・進行ステップ*],
        [*準備品・教材*],
      ),
      ..unbreakable-rows
    )
  } else if col-mode == 4 {
    table(
      columns: (54pt, 48pt, 80pt, 1fr),
      align: (col, row) => (
        if row == 0 { center + horizon }
        else if col == 0 { center + horizon }
        else if col == 1 { center + horizon }
        else if col == 2 { left + top }
        else { left + top }
      ),
      table.header(
        [*時間配分*],
        [*所要時間*],
        [*展開ステップ*],
        [*指導者・スタッフの動き / 演出・留意点*],
      ),
      ..unbreakable-rows
    )
  } else {
    table(
      columns: (52pt, 48pt, 70pt, 62pt, 1fr),
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
      ..unbreakable-rows
    )
  }
}

// ==============================================================================
// 3. 汎用公用文書テンプレート (session-doc) ★新設
// 「所員への依頼書」「隊集会実施計画書」「安全計画書」等の付属・関連書類で共通利用
// ==============================================================================

/// 汎用公用文書の全体レイアウト関数
/// - course-name: コース名
/// - document-type: 文書種別（例: "所員への依頼書", "隊集会実施計画書", "安全計画書"）
/// - session-id: セッション番号（例: "§1"）
/// - title: セッションタイトル（例: "班長訓練"）
/// - date: 実施日
/// - datetime-info: 日時情報
/// - role-name: 担当班・役務（任意）
/// - trainer-name: 担当者氏名
/// - body: 本文コンテンツ
#let session-doc(
  course-name: "",
  document-type: "公用文書",
  session-id: "",
  title: "",
  date: "",
  datetime-info: "",
  role-name: "",
  trainer-name: "",
  body,
) = {
  let session-label = if session-id != "" [#session-id. #title] else [#title]

  set page(.._apply-session-page-style(
    course-name: course-name,
    session-label: session-label,
    date: date,
    trainer-name: trainer-name,
  ))

  set text(
    font: default-doc-font-sans,
    size: 9.5pt,
    fill: rgb("#000000"),
    lang: "ja",
  )

  set par(
    leading: 0.6em,
    justify: true,
  )

  // レベル1見出し
  show heading.where(level: 1): it => block(
    width: 100%,
    stroke: (bottom: 1.2pt + black),
    inset: (bottom: 2.5pt),
    above: 12pt,
    below: 6pt,
  )[
    #text(weight: "bold", size: 10.5pt)[#it.body]
  ]

  // レベル2見出し
  show heading.where(level: 2): it => block(
    width: 100%,
    stroke: (bottom: (paint: black, thickness: 0.8pt, dash: "dashed")),
    inset: (bottom: 2.5pt),
    above: 9pt,
    below: 5pt,
  )[
    #text(weight: "bold", size: 9.5pt)[#it.body]
  ]

  // 1ページ目ヘッダー部：所属コース名・セッション情報・実施日
  block(width: 100%, inset: (bottom: 0pt))[
    #grid(
      columns: (1fr, auto),
      align: (left + bottom, right + bottom),
      [#text(8.5pt, fill: luma(70))[#course-name #if session-label != "" [ #h(4pt) #session-label]]],
      [#text(8.5pt, fill: luma(70))[#date]],
    )
    #v(1.5pt)
    #line(length: 100%, stroke: 0.4pt + border-gray)
  ]

  v(4pt)

  // メインタイトル（中央揃え・端正な計画書表題）
  align(center)[
    #block(
      width: 100%,
      stroke: (bottom: 1.2pt + black),
      inset: (bottom: 4pt),
    )[
      #text(16pt, weight: "bold", tracking: 2pt)[#document-type]
    ]
  ]

  if datetime-info != "" {
    v(1.5pt)
    align(right)[#text(8.5pt, fill: luma(80))[実施日時：#datetime-info]]
  }

  v(4pt)

  body
}
