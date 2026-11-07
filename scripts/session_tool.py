"""
セッション設定（session.toml）の読み込み、提出用ファイル名生成・エクスポート、
および新規セッション作成時のプリセット初期化を行うユーティリティ。
ボーイスカウト講習会（BS講習会）、ウッドバッジ研修所スカウトコース（WB研修所）、
団委員研修所（Dan）に対応。
"""

import argparse
import base64
import mimetypes
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

# ウッドバッジ研修所スカウトコース（WB研修所スカウトコース）標準プリセット定義
WB_KENSHUSHO_PRESETS: dict[str, dict[str, str]] = {
    "wb1": {
        "slug": "01-about-wb-kenshusho",
        "section_no": "01",
        "session_id": "§1",
        "title": "ウッドバッジ研修所について",
        "time_slot": "00:00〜00:45 (45分)",
    },
    "wb2": {
        "slug": "02-basic-movements",
        "section_no": "02",
        "session_id": "§2",
        "title": "基本動作",
        "time_slot": "00:00〜00:45 (45分)",
    },
    "wb3-1": {
        "slug": "03-1-scout-skills-pitching",
        "section_no": "03-1",
        "session_id": "§3-Ⅰ",
        "title": "スカウト技能（野営技能・設営）",
        "time_slot": "00:00〜00:45 (45分)",
    },
    "wb3-2": {
        "slug": "03-2-scout-skills-striking",
        "section_no": "03-2",
        "session_id": "§3-Ⅱ",
        "title": "スカウト技能（野営技能・撤営）",
        "time_slot": "00:00〜00:45 (45分)",
    },
    "wb4": {
        "slug": "04-outdoor-cooking",
        "section_no": "04",
        "session_id": "§4",
        "title": "野外炊事",
        "time_slot": "00:00〜00:45 (45分)",
    },
    "wb5": {
        "slug": "05-scout-movement",
        "section_no": "05",
        "session_id": "§5",
        "title": "スカウト運動",
        "time_slot": "00:00〜00:45 (45分)",
    },
    "wb6-1": {
        "slug": "06-1-night-program-wide-game",
        "section_no": "06-1",
        "session_id": "§6-Ⅰ",
        "title": "夜のプログラム（夜間ゲーム）",
        "time_slot": "00:00〜00:45 (45分)",
    },
    "wb6-2": {
        "slug": "06-2-night-program-campfire",
        "section_no": "06-2",
        "session_id": "§6-Ⅱ",
        "title": "夜のプログラム（キャンプファイア）",
        "time_slot": "00:00〜00:45 (45分)",
    },
    "wb6-3": {
        "slug": "06-3-night-program-welcome-fire",
        "section_no": "06-3",
        "session_id": "§6-Ⅲ",
        "title": "夜のプログラム（歓迎の営火）",
        "time_slot": "00:00〜00:45 (45分)",
    },
    "wb7": {
        "slug": "07-safety-in-scouting",
        "section_no": "07",
        "session_id": "§7",
        "title": "スカウト活動における安全",
        "time_slot": "00:00〜00:45 (45分)",
    },
    "wb8": {
        "slug": "08-patrol-leaders-training",
        "section_no": "08",
        "session_id": "§8",
        "title": "班長訓練",
        "time_slot": "00:00〜00:45 (45分)",
    },
    "wb9": {
        "slug": "09-patrol-meeting",
        "section_no": "09",
        "session_id": "§9",
        "title": "班集会",
        "time_slot": "00:00〜00:45 (45分)",
    },
    "wb10": {
        "slug": "10-scout-method",
        "section_no": "10",
        "session_id": "§10",
        "title": "スカウト教育法",
        "time_slot": "00:00〜00:45 (45分)",
    },
    "wb11": {
        "slug": "11-patrol-activity-hike",
        "section_no": "11",
        "session_id": "§11",
        "title": "班の活動（班ハイク）",
        "time_slot": "00:00〜00:45 (45分)",
    },
    "wb12": {
        "slug": "12-troop-meeting",
        "section_no": "12",
        "session_id": "§12",
        "title": "隊集会",
        "time_slot": "00:00〜00:45 (45分)",
    },
    "wb13": {
        "slug": "13-safety-operations",
        "section_no": "13",
        "session_id": "§13",
        "title": "安全の運用",
        "time_slot": "00:00〜00:45 (45分)",
    },
    "wb14": {
        "slug": "14-role-and-responsibilities",
        "section_no": "14",
        "session_id": "§14",
        "title": "隊指導者の役割と責務",
        "time_slot": "00:00〜00:45 (45分)",
    },
}

# 団委員研修所 標準プリセット定義
DAN_IIN_KENSHUSHO_PRESETS: dict[str, dict[str, str]] = {
    "dan1": {
        "slug": "01-about-dan-iin-kenshusho",
        "section_no": "01",
        "session_id": "§1",
        "title": "団委員研修所について",
        "time_slot": "00:00〜00:45 (45分)",
    },
    "dan2": {
        "slug": "02-scout-movement",
        "section_no": "02",
        "session_id": "§2",
        "title": "スカウト運動",
        "time_slot": "00:00〜00:45 (45分)",
    },
    "dan3": {
        "slug": "03-group-organization",
        "section_no": "03",
        "session_id": "§3",
        "title": "団の組織",
        "time_slot": "00:00〜00:45 (45分)",
    },
    "dan4": {
        "slug": "04-sponsoring-body-and-committee",
        "section_no": "04",
        "session_id": "§4",
        "title": "育成会と団委員会",
        "time_slot": "00:00〜00:45 (45分)",
    },
    "dan5": {
        "slug": "05-committee-organization-and-functions",
        "section_no": "05",
        "session_id": "§5",
        "title": "団委員会の組織と機能",
        "time_slot": "00:00〜00:45 (45分)",
    },
    "dan6": {
        "slug": "06-committee-administration",
        "section_no": "06",
        "session_id": "§6",
        "title": "団委員会の事務と業務",
        "time_slot": "00:00〜00:45 (45分)",
    },
    "dan7": {
        "slug": "07-leader-training-and-support",
        "section_no": "07",
        "session_id": "§7",
        "title": "隊指導者の養成と支援",
        "time_slot": "00:00〜00:45 (45分)",
    },
    "dan8": {
        "slug": "08-group-council",
        "section_no": "08",
        "session_id": "§8",
        "title": "団会議",
        "time_slot": "00:00〜00:45 (45分)",
    },
    "dan9": {
        "slug": "09-scout-advancement-and-committee",
        "section_no": "09",
        "session_id": "§9",
        "title": "スカウトの進級と団委員会",
        "time_slot": "00:00〜00:45 (45分)",
    },
    "dan10": {
        "slug": "10-safety-plan",
        "section_no": "10",
        "session_id": "§10",
        "title": "安全計画",
        "time_slot": "00:00〜00:45 (45分)",
    },
    "dan11": {
        "slug": "11-safety-measures-and-risk-management",
        "section_no": "11",
        "session_id": "§11",
        "title": "安全対策と危機管理",
        "time_slot": "00:00〜00:45 (45分)",
    },
    "dan12": {
        "slug": "12-how-to-support-troops",
        "section_no": "12",
        "session_id": "§12",
        "title": "隊を支援する方法",
        "time_slot": "00:00〜00:45 (45分)",
    },
    "dan13": {
        "slug": "13-committee-and-council-collaboration",
        "section_no": "13",
        "session_id": "§13",
        "title": "団委員会と団会議の連携",
        "time_slot": "00:00〜00:45 (45分)",
    },
    "dan14": {
        "slug": "14-group-annual-plan",
        "section_no": "14",
        "session_id": "§14",
        "title": "団の年間計画",
        "time_slot": "00:00〜00:45 (45分)",
    },
    "dan15": {
        "slug": "15-scout-recruitment",
        "section_no": "15",
        "session_id": "§15",
        "title": "スカウト募集",
        "time_slot": "00:00〜00:45 (45分)",
    },
    "dan16": {
        "slug": "16-support-for-group",
        "section_no": "16",
        "session_id": "§16",
        "title": "団への支援",
        "time_slot": "00:00〜00:45 (45分)",
    },
}

ALL_PRESETS: dict[str, dict[str, str]] = {
    **BS_KOSHUKAI_PRESETS,
    **WB_KENSHUSHO_PRESETS,
    **DAN_IIN_KENSHUSHO_PRESETS,
}

# 開催県連盟名の自動判定用マッピング（ローマ字 ➔ 正式県連名略称）
PREFECTURE_MAP: dict[str, str] = {
    "hokkaido": "北海道", "aomori": "青森", "iwate": "岩手", "miyagi": "宮城",
    "akita": "秋田", "yamagata": "山形", "fukushima": "福島", "ibaraki": "茨城",
    "tochigi": "栃木", "gunma": "群馬", "saitama": "埼玉", "chiba": "千葉",
    "tokyo": "東京", "kanagawa": "神奈川", "niigata": "新潟", "toyama": "富山",
    "ishikawa": "石川", "fukui": "福井", "yamanashi": "山梨", "nagano": "長野",
    "gifu": "岐阜", "shizuoka": "静岡", "aichi": "愛知", "mie": "三重",
    "shiga": "滋賀", "kyoto": "京都", "osaka": "大阪", "hyogo": "兵庫",
    "nara": "奈良", "wakayama": "和歌山", "tottori": "鳥取", "shimane": "島根",
    "okayama": "岡山", "hiroshima": "広島", "yamaguchi": "山口", "tokushima": "徳島",
    "kagawa": "香川", "ehime": "愛媛", "kochi": "高知", "fukuoka": "福岡",
    "saga": "佐賀", "nagasaki": "長崎", "kumamoto": "熊本", "oita": "大分",
    "miyazaki": "宮崎", "kagoshima": "鹿児島", "okinawa": "沖縄",
}


def _extract_prefecture(path_str: str) -> str | None:
    """
    パス文字列（フォルダ名等）から開催県連盟名を判定して返す。
    例: "2026-11-21-wb-sc-20th-hyogo" -> "兵庫"
    """
    path_lower = path_str.lower()
    for romaji, kanji in PREFECTURE_MAP.items():
        if re.search(rf"\b{romaji}\b", path_lower) or romaji in path_lower:
            return kanji
        if kanji in path_str:
            return kanji
    return None


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

    if suffix == ".md":
        candidates = [session_dir / f"{stem}.pdf", session_dir / f"{stem}.html"]
    elif suffix == ".typ":
        candidates = [session_dir / f"{stem}.pdf"]
    else:
        candidates = [session_dir / source_name]

    return [p for p in candidates if p.is_file()]


def inline_html_assets(html_path: Path, base_dir: Path) -> bool:
    """
    HTML ファイル内のローカル画像相対パス参照を Base64 Data URI にインライン化し、
    外部アセットファイルなしで完全に自己完結して表示できるようにする。

    @param html_path 対象の HTML ファイルパス
    @param base_dir 相対パス解決の起点ディレクトリ
    @returns 置換が行われたかどうか
    """
    if not html_path.is_file():
        return False

    content = html_path.read_text(encoding="utf-8")

    def _replace_src(match: re.Match[str]) -> str:
        src = match.group(1)
        if src.startswith(("data:", "http://", "https://", "//")):
            return match.group(0)

        img_path = (base_dir / src).resolve()
        if img_path.is_file():
            mime, _ = mimetypes.guess_type(img_path)
            if not mime:
                ext = img_path.suffix.lower()
                mime = "image/jpeg" if ext in (".jpg", ".jpeg") else "image/png"
            b64 = base64.b64encode(img_path.read_bytes()).decode("ascii")
            return f'src="data:{mime};base64,{b64}"'
        return match.group(0)

    pattern = re.compile(r'src=["\']([^"\']+\.(?:png|jpe?g|gif|svg|webp))["\']', re.IGNORECASE)
    new_content, count = pattern.subn(_replace_src, content)
    if count > 0:
        html_path.write_text(new_content, encoding="utf-8")
        return True
    return False


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
    if dist_dir.exists():
        shutil.rmtree(dist_dir)
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
            if dest_path.suffix.lower() == ".html":
                inline_html_assets(dest_path, session_dir)
            exported.append(dest_path)

    return exported


def _resolve_preset(session_dir: Path, preset_key: str | None) -> dict[str, str]:
    """
    指定されたプリセット名またはディレクトリ階層からセッション初期値を解決する。

    @param session_dir セッションディレクトリのパス
    @param preset_key 明示指定されたプリセットキー（"bs1"〜"bs5", "wb1"〜"wb14", "dan1"〜"dan16" または None）
    @returns セッション初期値の辞書
    """
    if preset_key and preset_key in ALL_PRESETS:
        return ALL_PRESETS[preset_key]

    # パス名から訓練種別およびセッションの slug を自動判定する
    parts = [p.lower() for p in session_dir.parts]
    if "01-bs-koshukai" in parts:
        target_presets = BS_KOSHUKAI_PRESETS
    elif "02-wb-kenshusho-scout-course" in parts or "02-wb-kenshusho" in parts:
        target_presets = WB_KENSHUSHO_PRESETS
    elif "03-dan-iin-kenshusho" in parts:
        target_presets = DAN_IIN_KENSHUSHO_PRESETS
    else:
        target_presets = ALL_PRESETS

    for _k, preset in target_presets.items():
        if preset["slug"] in parts:
            return preset

    for _k, preset in ALL_PRESETS.items():
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
    pref: str | None = None,
    term: str | None = None,
    trainer_name: str = "指導 太郎",
) -> Path:
    """
    新規セッションディレクトリにプリセットおよびパス推定を反映した session.toml を生成する。

    @param session_dir 対象セッションディレクトリのパス
    @param preset プリセットキー（"bs1"〜"bs5", "wb1"〜"wb14", "dan1"〜"dan16"、省略時はパスから自動判定）
    @param event_short ファイル名末尾の講習会・研修所略称（省略時はパスから自動判定）
    @param course_name ドキュメントヘッダーのコース名（省略時はパスから自動判定）
    @param pref 開催県連盟名（例: "兵庫", "大阪", "京都" 等、省略時はパスから自動判定）
    @param term 期番号・回数（例: "20", "1156" 等、省略時はパスから自動判定）
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
    path_lower = path_str.lower()
    date_match = re.search(r"(\d{4})-(\d{1,2})-(\d{1,2})", path_str)
    if date_match:
        y, m, d = int(date_match.group(1)), int(date_match.group(2)), int(date_match.group(3))
        date_str = f"{y}年{m}月{d}日"
        datetime_info = f"{date_str} {time_slot}"
    else:
        date_str = "20xx年〇月〇日"
        datetime_info = f"{date_str}(〇) {time_slot}"

    # 期番号・回数の抽出（例: 1156th, 20th, 第20期, 1156回、引数 term があれば優先）
    num_match = re.search(r"(\d+)(?:th|期|回)", path_str)
    num = term or (num_match.group(1) if num_match else None)

    # 開催県連盟名の判定（引数 pref があれば最優先、なければパスから自動抽出）
    detected_pref = pref or _extract_prefecture(path_str) or ""

    if not course_name:
        if "bs-koshukai" in path_lower:
            course_name = f"第{num}回ボーイスカウト講習会" if num else "ボーイスカウト講習会"
        elif "wb-kenshusho" in path_lower:
            p_name = detected_pref if detected_pref else "〇〇"
            t_str = f"第{num}期" if num else "第〇期"
            course_name = f"WB研修所スカウトコース{p_name}{t_str}"
        elif "dan-iin-kenshusho" in path_lower:
            t_str = f"第{num}期" if num else "第〇期"
            if "altc" in path_lower:
                course_name = f"団委員研修所（ALTC{t_str} 課題）"
            else:
                p_name = detected_pref if detected_pref else "〇〇"
                course_name = f"団委員研修所{p_name}{t_str}"
        else:
            course_name = "20xx年度 指導者研修コース"

    if not event_short:
        if "altc" in path_lower:
            event_short = f"ALTC{num}期課題" if num else "ALTC〇〇期課題"
        elif "bs-koshukai" in path_lower:
            event_short = f"{num}回BS講習会" if num else "〇〇回BS講習会"
        elif "wb-kenshusho" in path_lower:
            p_name = detected_pref if detected_pref else ""
            t_str = f"第{num}期" if num else "第〇期"
            event_short = f"WB研修所スカウトコース{p_name}{t_str}"
        elif "dan-iin-kenshusho" in path_lower:
            p_name = detected_pref if detected_pref else ""
            t_str = f"第{num}期" if num else "第〇期"
            event_short = f"団委員研修所{p_name}{t_str}"
        else:
            event_short = "〇〇回講習会"

    # 確定連番ルール: 00番台は基本パッケージ（スライド00、進め方01、口述02、配布資料03）
    # 10番台は現場計画書群（隊集会計画書11、所員依頼書12、安全計画書13）
    if section_no == "02":
        extra_files = """[files.script]
sub_no = "02"
label  = "口述要項"
source = "script.typ"

[files.safety_plan]
sub_no = "13"
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
label  = "受講者配布資料"
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

# ドキュメント（要項・口述要項・配布資料・計画書）ヘッダー用メタデータ
course_name   = "{course_name}"
date          = "{date_str}"
datetime_info = "{datetime_info}"
role_name     = ""
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


def main(argv: list[str] | None = None) -> None:
    """CLI エントリーポイント"""
    parser = argparse.ArgumentParser(description="ボーイスカウト指導者訓練 セッション成果物管理ツール")
    sub = parser.add_subparsers(dest="command", required=True)

    export_p = sub.add_parser("export", help="ビルド済み成果物を dist/ に正式ファイル名で出力")
    export_p.add_argument("session_dir", type=Path, help="セッションディレクトリのパス")

    bundle_p = sub.add_parser("bundle-html", help="HTML内のローカル画像をBase64にインライン化")
    bundle_p.add_argument("html_path", type=Path, help="対象HTMLファイルのパス")
    bundle_p.add_argument("--base-dir", type=Path, default=None, help="相対パス解決の起点ディレクトリ")

    init_p = sub.add_parser("init", help="session.toml をプリセットまたはパスから初期化")
    init_p.add_argument("session_dir", type=Path, help="セッションディレクトリのパス")
    init_p.add_argument("--preset", default=None, help="プリセット名 (bs1〜bs5, wb1〜wb14, dan1〜dan16)")
    init_p.add_argument("--event", default=None, help="講習会略称 (例: 1156回BS講習会)")
    init_p.add_argument("--course", default=None, help="コース正式名")
    init_p.add_argument("--pref", default=None, help="開催県連盟名 (例: 兵庫, 大阪, 京都)")
    init_p.add_argument("--term", default=None, help="期番号または回数 (例: 20, 1156)")
    init_p.add_argument("--trainer", default="指導 太郎", help="担当トレーナー氏名")

    args = parser.parse_args(argv)

    if args.command == "export":
        files = export_session_dist(args.session_dir)
        print(f"▶ 提出・共有用ファイルを出力しました ({args.session_dir / 'dist'}):")
        for f in sorted(files):
            print(f"  ✓ {f.name}")
    elif args.command == "bundle-html":
        base_dir = args.base_dir or args.html_path.parent
        changed = inline_html_assets(args.html_path, base_dir)
        if changed:
            print(f"✓ HTML内のローカル画像をBase64にインライン化しました: {args.html_path}")
        else:
            print(f"・インライン化対象のローカル画像はありませんでした: {args.html_path}")
    elif args.command == "init":
        toml_path = init_session_toml(
            args.session_dir,
            preset=args.preset,
            event_short=args.event,
            course_name=args.course,
            pref=args.pref,
            term=args.term,
            trainer_name=args.trainer,
        )
        print(f"✓ セッション設定ファイルを生成しました: {toml_path}")


if __name__ == "__main__":
    main()
