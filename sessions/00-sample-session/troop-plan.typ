#import "/templates/session-doc-template.typ": session-doc
#let cfg = toml("session.toml")

#show: session-doc.with(
  course-name: cfg.course_name,
  document-type: cfg.files.troop_plan.label,
  session-id: cfg.session_id,
  title: cfg.title,
  date: cfg.date,
  datetime-info: cfg.datetime_info,
  role-name: cfg.role_name,
  trainer-name: cfg.trainer_name,
)

// 隊集会実施計画書 ヘッダー情報表
#align(center)[
  #text(12pt, weight: "bold")[2026年度 〈10月〉隊集会実施計画書]
  #h(1fr)
  #text(9pt)[新城吉川第1団 ボーイスカウト隊]
]

#v(2pt)

#set table(stroke: 0.5pt + black)

#table(
  columns: (70pt, 1.2fr, 70pt, 1.2fr),
  inset: (x: 5pt, y: 4pt),
  [*集会日時*], [2026年10月10日(土) 13:30〜15:00],
  [*集会場所*], [第4セレモニー広場],
  [*今月のテーマ*], [新城って？（地域の歴史と自然）],
  [*当番班*], [ふくろう班],
  [*活動分野*], [追跡・野外活動],
  [*関連進歩*], [読図、計測、通信],
  table.cell(colspan: 4)[
    *隊集会の目標*:
    1. 地域の郷土の歴史に触れ、スカウトスキルを活用した活動を体験する。\
    2. 対班競点により班意識の向上を目指す。
  ],
)

#v(4pt)

#text(10pt, weight: "bold")[〈プログラム〉]

#v(2pt)

#table(
  columns: (52pt, 40pt, 46pt, 1fr, 72pt),
  inset: (x: 4pt, y: 3.5pt),
  align: (col, row) => (
    if row == 0 { center + horizon }
    else if col == 1 { center + top }
    else if col == 2 { center + top }
    else { left + top }
  ),
  fill: (col, row) => if row == 0 { luma(235) } else { none },
  table.header(
    [*項目*], [*時間*], [*担当者*], [*内　容*], [*準備品*]
  ),
  [開会前], [13:20], [ふくろう班], [当番班は集会場所整頓、国旗掲揚準備], [国旗],
  [開会式], [13:30], [上班\ 副長\ 隊長], [
    ・整頓、班報告、点検\
    ・国旗掲揚（ふくろう班）\
    ・隊長の話、ソング「平和の騎士」
  ], [ソング集],
  [オリエン\ テーション], [13:40], [隊長], [この地域における郷土の歴史について簡潔に説明する。], [資料],
  [活動], [13:45], [隊長\ 上班], [
    *想定番・指令書の発表*\
    *活動① ハイキング・読図*\
    ・座標が記入された地図を使用して目的地へ到達する\
    *活動② 通信（手旗信号）*\
    ・片仮名手旗信号で20文字以上の文章を発信、受信できる\
    *活動③ 計測*\
    ・簡易計測法を用い、到達できない2点間の距離を測る\
    *活動④ ロープ結び*\
    ・よろい結び、馬つなぎ
  ], [
    想定文\
    指令文\
    コンパス\
    手旗\
    簡易測量器\
    ロープ
  ],
  [講評と表彰], [14:40], [隊長\ 団委員長], [
    ・それぞれの班の活動について講評および優秀班表彰\
    ・進歩記録の確認・進歩章授与
  ], [優秀旗\ 記章類],
  [閉会式], [14:50], [隊長\ 副長], [
    ・隊長の話、ソング\
    ・国旗降納（ふくろう班）
  ], [],
  [閉会後], [15:00], [上班\ 班長], [後片付け、班長会議（反省と次回予定）], [],
)
