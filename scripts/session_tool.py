"""
セッション設定（session.toml）の読み込み、提出用ファイル名生成・エクスポート、
および新規セッション作成時のプリセット初期化を行うユーティリティ。
"""

import argparse
from pathlib import Path
import re
import shutil
import sys
from typing import Any

try:
    import tomllib  # type: ignore[import-not-found]
except ImportError:
    tomllib = None  # type: ignore[assignment]


# ボーイスカウト講習会（導入訓練）基本日程例に基づく標準プリセット定義
BS_KOSHUKAI_PRESETS: dict[str, dict[str, str]] = {
    "bs1": {
        "slug": "01-world-scouting",
        "section_no": "01",
        "session_id": "§1",
        "title": "世界に広がるボーイスカウト",
        "time_slot": "10:00〜10:40 (40分)",
    },
    "bs2": {
        "slug": "02-pleasant-hiking",
        "section_no": "02",
        "session_id": "§2",
        "title": "愉快なハイキング",
        "time_slot": "10:45〜13:35 (170分)",
    },
    "bs3": {
        "slug": "03-what-is-scouting",
        "section_no": "03",
        "session_id": "§3",
        "title": "スカウティングって何だろう",
        "time_slot": "13:45〜14:55 (70分)",
    },
    "bs4": {
        "slug": "04-supporting-people",
        "section_no": "04",
        "session_id": "§4",
        "title": "スカウティングを支える人たち",
        "time_slot": "15:00〜15:30 (30分)",
    },
    "bs5": {
        "slug": "05-future-of-youth",
        "section_no": "05",
        "session_id": "§5",
        "title": "青少年の未来のために",
        "time_slot": "15:35〜16:15 (40分)",
    },
}


def load_session_config(toml_path: Path) -> dict[str, Any]:
    """
    session.toml ファイルを読み込んで辞書として返す。

    @param toml_path session.toml のファイルパス
    @returns パースされた設定データの辞書
    """
    text = toml_path.read_text(encoding="utf-8")
    if tomllib is not None:
        return tomllib.loads(text)

    # Python 3.10以前の環境でも外部ライブラリなしで動作させるためのフォールバック
    result: dict[str, Any] = {}
    current_section: dict[str, Any] = result
    for raw_line in text.splitlines():
        line = raw_line.strip()
        if not line or line.startswith("#"):
            continue
        sec_match = re.match(r"^\[([^\]]+)\]$", line)
        if sec_match:
            keys = sec_match.group(1).split(".")
            current_section = result
            for k in keys:
                current_section = current_section.setdefault(k, {})
            continue
        kv_match = re.match(r'^([A-Za-z0-9_-]+)\s*=\s*"(.*)"$', line)
        if kv_match:
            current_section[kv_match.group(1)] = kv_match.group(2)
    return result


def format_dist_filename(
    config: dict[str, Any], file_entry: dict[str, str], ext: str
) -> str:
    """
    セッション設定とファイル定義から、提出・共有用の正式ファイル名を生成する。

    @param config セッション基本設定（section_no, session_name, event_short を含む辞書）
    @param file_entry ファイル定義（sub_no, label を含む辞書）
    @param ext 出力ファイルの拡張子（ドット付き、例: ".pdf", ".html"）
    @returns "{section_no}-{sub_no}_{session_name}_{label}_{event_short}{ext}" 形式の文字列
    """
    # Google Drive上で番号順ソートと一覧性を両立するため、連盟・講習会の慣例書式に従う
    section_no = config["section_no"]
    sub_no = file_entry["sub_no"]
    session_name = config["session_name"]
    label = file_entry["label"]
    event_short = config["event_short"]
    if not ext.startswith("."):
        ext = f".{ext}"
    return f"{section_no}-{sub_no}_{session_name}_{label}_{event_short}{ext}"


def _resolve_built_artifacts(session_dir: Path, source_name: str) -> list[Path]:
    """
    ソースファイル名に対応するビルド済み成果物（PDF/HTML等）のパス一覧を解決する。

    @param session_dir セッションディレクトリのパス
    @param source_name ソースファイル名（例: "slides.md", "plan.typ"）
    @returns 存在するビルド済み成果物のパス一覧
    """
    src_path = Path(source_name)
    stem = src_path.stem
    suffix = src_path.suffix.lower()

    # MarpスライドはPDFとHTMLの両方を提出・上映用に書き出すため両方対象とする
    if suffix == ".md":
        candidates = [session_dir / f"{stem}.pdf", session_dir / f"{stem}.html"]
    elif suffix == ".typ":
        candidates = [session_dir / f"{stem}.pdf"]
    else:
        candidates = [session_dir / source_name]

    return [p for p in candidates if p.is_file()]


def export_session_dist(session_dir: Path) -> list[Path]:
    """
    session.toml の定義に基づき、ビルド済み成果物を正式ファイル名で dist/ に出力する。

    @param session_dir 対象セッションディレクトリのパス
    @returns dist/ に出力されたファイルの Path リスト
    """
    toml_path = session_dir / "session.toml"
    if not toml_path.is_file():
        return []

    config = load_session_config(toml_path)
    dist_dir = session_dir / "dist"
    dist_dir.mkdir(parents=True, exist_ok=True)

    exported: list[Path] = []
    files_cfg = config.get("files", {})
    for _key, entry in files_cfg.items():
        source_name = entry.get("source", "")
        if not source_name:
            continue
        for artifact in _resolve_built_artifacts(session_dir, source_name):
            dest_name = format_dist_filename(config, entry, artifact.suffix)
            dest_path = dist_dir / dest_name
            shutil.copy2(artifact, dest_path)
            exported.append(dest_path)

    return exported


def _resolve_preset(session_dir: Path, preset_key: str | None) -> dict[str, str]:
    """
    指定されたプリセット名またはディレクトリ階層からセッション初期値を解決する。

    @param session_dir セッションディレクトリのパス
    @param preset_key 明示指定されたプリセットキー（"bs1"〜"bs5" または None）
    @returns セッション初期値の辞書
    """
    if preset_key and preset_key in BS_KOSHUKAI_PRESETS:
        return BS_KOSHUKAI_PRESETS[preset_key]

    # パス名に 01-world-scouting 等が含まれていれば自動的に該当プリセットを適用する
    parts = [p.lower() for p in session_dir.parts]
    for _k, preset in BS_KOSHUKAI_PRESETS.items():
        if preset["slug"] in parts:
            return preset

    return {
        "slug": "custom",
        "section_no": "01",
        "session_id": "§1",
        "title": "セッション名（サンプル）",
        "time_slot": "00:00〜00:45 (45分)",
    }


def init_session_toml(
    session_dir: Path,
    preset: str | None = None,
    event_short: str | None = None,
    course_name: str | None = None,
    trainer_name: str = "指導 太郎",
) -> Path:
    """
    新規セッションディレクトリにプリセットおよびパス推定を反映した session.toml を生成する。

    @param session_dir 対象セッションディレクトリのパス
    @param preset BS講習会プリセットキー（"bs1"〜"bs5"、省略時はパスから自動判定）
    @param event_short ファイル名末尾の講習会略称（省略時はパスから自動判定）
    @param course_name ドキュメントヘッダーのコース名（省略時はパスから自動判定）
    @param trainer_name 担当トレーナー氏名
    @returns 生成された session.toml の Path
    """
    preset_info = _resolve_preset(session_dir, preset)
    section_no = preset_info["section_no"]
    session_id = preset_info["session_id"]
    title = preset_info["title"]
    session_name = f"{session_id}. {title}"
    time_slot = preset_info["time_slot"]

    # フォルダ名（例: 2026-11-08-1156th-hyogo）から日付と回次を自動抽出して手入力を省力化する
    path_str = "/".join(session_dir.parts)
    date_match = re.search(r"(\d{4})-(\d{1,2})-(\d{1,2})", path_str)
    if date_match:
        y, m, d = int(date_match.group(1)), int(date_match.group(2)), int(date_match.group(3))
        date_str = f"{y}年{m}月{d}日"
        datetime_info = f"{date_str} {time_slot}"
    else:
        date_str = "20xx年〇月〇日"
        datetime_info = f"{date_str}(〇) {time_slot}"

    num_match = re.search(r"(\d+)th", path_str)
    if not event_short:
        if num_match and "bs-koshukai" in path_str.lower():
            event_short = f"{num_match.group(1)}回BS講習会"
        else:
            event_short = "〇〇回BS講習会"

    if not course_name:
        if num_match and "bs-koshukai" in path_str.lower():
            course_name = f"第{num_match.group(1)}回ボーイスカウト講習会"
        else:
            course_name = "20xx年度 指導者研修コース"

    # §2（ハイキング）は現場計画書群(02〜10)が入るため口述要項を11・安全計画書を12とする
    if section_no == "02":
        extra_files = """[files.script]
sub_no = "11"
label  = "口述要項"
source = "script.typ"

[files.safety_plan]
sub_no = "12"
label  = "安全計画書"
source = "safety-plan.typ"
"""
    else:
        extra_files = """[files.script]
sub_no = "02"
label  = "口述要項"
source = "script.typ"

[files.handout]
sub_no = "03"
label  = "配布資料"
source = "handout.typ"
"""

    content = f"""# ==============================================================================
# セッション設定ファイル (session.toml)
# ここを変更するだけで、提出用ファイル名（dist/）とドキュメントのヘッダーが一括更新されます。
# ==============================================================================

section_no    = "{section_no}"
session_id    = "{session_id}"
title         = "{title}"
session_name  = "{session_name}"
event_short   = "{event_short}"

# ドキュメント（要項・口述要項・配布資料）ヘッダー用メタデータ
course_name   = "{course_name}"
date          = "{date_str}"
datetime_info = "{datetime_info}"
trainer_name  = "{trainer_name}"

# ==============================================================================
# 提出・Google Drive共有用ファイル出力定義 (dist/)
# 出力形式: {{section_no}}-{{sub_no}}_{{session_name}}_{{label}}_{{event_short}}.{{ext}}
# ==============================================================================

[files.slides]
sub_no = "00"
label  = "スライド資料"
source = "slides.md"

[files.plan]
sub_no = "01"
label  = "セッションの進め方"
source = "plan.typ"

{extra_files}"""

    toml_path = session_dir / "session.toml"
    toml_path.write_text(content, encoding="utf-8")

    slides_path = session_dir / "slides.md"
    if slides_path.is_file():
        # サンプルから複製された slides.md のヘッダー・タイトル・相対アセットパスを階層に合わせて調整する
        parts = list(session_dir.parts)
        depth_from_root = len(parts) - parts.index("sessions") if "sessions" in parts else 2
        rel_assets = "../" * depth_from_root + "assets/"
        slides_text = slides_path.read_text(encoding="utf-8")
        slides_text = slides_text.replace("../../assets/", rel_assets)
        slides_text = slides_text.replace("20xx年度 指導者研修コース", course_name)
        slides_text = slides_text.replace(
            "§1. セッション名（担当：指導 太郎）",
            f"{session_name}（担当：{trainer_name}）",
        )
        slides_text = slides_text.replace("# セッション名（サンプル）", f"# {session_name}")
        slides_text = slides_text.replace("20xx年〇月〇日(〇) 00:00〜00:45", datetime_info)
        slides_text = slides_text.replace("20xx年〇月〇日", date_str)
        slides_path.write_text(slides_text, encoding="utf-8")

    return toml_path


def main(argv: list[str] | None = None) -> int:
    """
    CLI エントリポイント。

    @param argv コマンドライン引数リスト
    @returns 終了コード（0: 正常終了）
    """
    parser = argparse.ArgumentParser(description="セッション設定・提出用ファイル整理ツール")
    sub = parser.add_subparsers(dest="command", required=True)

    exp_p = sub.add_parser("export", help="ビルド済み成果物を正式ファイル名で dist/ に出力")
    exp_p.add_argument("session_dir", type=Path, help="セッションディレクトリのパス")

    init_p = sub.add_parser("init", help="session.toml をプリセットまたはパスから初期化")
    init_p.add_argument("session_dir", type=Path, help="セッションディレクトリのパス")
    init_p.add_argument("--preset", default=None, help="プリセット名 (bs1〜bs5)")
    init_p.add_argument("--event", default=None, help="講習会略称 (例: 1156回BS講習会)")
    init_p.add_argument("--course", default=None, help="コース正式名")
    init_p.add_argument("--trainer", default="指導 太郎", help="担当トレーナー氏名")

    args = parser.parse_args(argv)
    if args.command == "export":
        exported = export_session_dist(args.session_dir)
        if exported:
            print(f"▶ 提出・共有用ファイルを出力しました ({args.session_dir / 'dist'}):")
            for p in exported:
                print(f"  ✓ {p.name}")
        return 0

    if args.command == "init":
        toml_path = init_session_toml(
            args.session_dir,
            preset=args.preset,
            event_short=args.event,
            course_name=args.course,
            trainer_name=args.trainer,
        )
        print(f"✓ セッション設定ファイルを生成しました: {toml_path}")
        return 0

    return 0


if __name__ == "__main__":
    sys.exit(main())
