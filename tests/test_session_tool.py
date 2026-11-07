import tempfile
from pathlib import Path
import unittest
from scripts.session_tool import (
    format_dist_filename,
    export_session_dist,
    init_session_toml,
    load_session_config,
)


class TestSessionTool(unittest.TestCase):
    def test_format_dist_filename_generates_official_naming_pattern(self):
        config = {
            "section_no": "02",
            "session_name": "§2. 愉快なハイキング",
            "event_short": "1156回BS講習会",
        }
        file_entry = {
            "sub_no": "11",
            "label": "口述要項",
            "source": "script.typ",
        }

        actual = format_dist_filename(config, file_entry, ".pdf")
        self.assertEqual(
            actual,
            "02-11_§2. 愉快なハイキング_口述要項_1156回BS講習会.pdf",
        )

    def test_export_session_dist_copies_built_artifacts_and_skips_missing(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            session_dir = Path(tmpdir)
            (session_dir / "session.toml").write_text(
                """
section_no = "02"
session_name = "§2. 愉快なハイキング"
event_short = "1156回BS講習会"

[files.slides]
sub_no = "00"
label = "スライド資料"
source = "slides.md"

[files.plan]
sub_no = "01"
label = "セッションの進め方"
source = "plan.typ"

[files.handout]
sub_no = "03"
label = "配布資料"
source = "handout.typ"
""".strip(),
                encoding="utf-8",
            )
            # ビルド済み成果物を用意（handout.pdf は存在しないケース）
            (session_dir / "slides.pdf").write_bytes(b"pdf-slides")
            (session_dir / "slides.html").write_text("<html></html>", encoding="utf-8")
            (session_dir / "plan.pdf").write_bytes(b"pdf-plan")

            exported = export_session_dist(session_dir)
            exported_names = sorted(p.name for p in exported)

            self.assertEqual(
                exported_names,
                [
                    "02-00_§2. 愉快なハイキング_スライド資料_1156回BS講習会.html",
                    "02-00_§2. 愉快なハイキング_スライド資料_1156回BS講習会.pdf",
                    "02-01_§2. 愉快なハイキング_セッションの進め方_1156回BS講習会.pdf",
                ],
            )
            dist_dir = session_dir / "dist"
            self.assertEqual(
                (dist_dir / "02-01_§2. 愉快なハイキング_セッションの進め方_1156回BS講習会.pdf").read_bytes(),
                b"pdf-plan",
            )
            # clean_intermediates=False (デフォルト) のため、元ファイルが残っていること
            self.assertTrue((session_dir / "slides.pdf").is_file())
            self.assertTrue((session_dir / "plan.pdf").is_file())

    def test_export_session_dist_cleans_intermediate_pdfs_when_clean_is_true(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            session_dir = Path(tmpdir)
            (session_dir / "session.toml").write_text(
                """
section_no = "02"
session_name = "§2. 愉快なハイキング"
event_short = "1156回BS講習会"

[files.slides]
sub_no = "00"
label = "スライド資料"
source = "slides.md"

[files.plan]
sub_no = "01"
label = "セッションの進め方"
source = "plan.typ"
""".strip(),
                encoding="utf-8",
            )
            # ソースファイルと中間生成物を用意
            (session_dir / "slides.md").write_text("# スライド", encoding="utf-8")
            (session_dir / "plan.typ").write_text("= 進め方", encoding="utf-8")
            (session_dir / "slides.pdf").write_bytes(b"pdf-slides")
            (session_dir / "slides.html").write_text("<html></html>", encoding="utf-8")
            (session_dir / "plan.pdf").write_bytes(b"pdf-plan")

            exported = export_session_dist(session_dir, clean_intermediates=True)

            # 1. dist/ に成果物がエクスポートされていること
            dist_dir = session_dir / "dist"
            self.assertTrue((dist_dir / "02-00_§2. 愉快なハイキング_スライド資料_1156回BS講習会.pdf").is_file())
            self.assertTrue((dist_dir / "02-01_§2. 愉快なハイキング_セッションの進め方_1156回BS講習会.pdf").is_file())

            # 2. ソースファイルが保持されていること
            self.assertTrue((session_dir / "session.toml").is_file())
            self.assertTrue((session_dir / "slides.md").is_file())
            self.assertTrue((session_dir / "plan.typ").is_file())

            # 3. セッション直下の中間 PDF が削除されていること
            self.assertFalse((session_dir / "slides.pdf").exists())
            self.assertFalse((session_dir / "plan.pdf").exists())

    def test_cli_export_with_clean_flag_deletes_intermediate_pdfs(self):
        from scripts.session_tool import main

        with tempfile.TemporaryDirectory() as tmpdir:
            session_dir = Path(tmpdir)
            (session_dir / "session.toml").write_text(
                """
section_no = "02"
session_name = "§2. 愉快なハイキング"
event_short = "1156回BS講習会"

[files.plan]
sub_no = "01"
label = "セッションの進め方"
source = "plan.typ"
""".strip(),
                encoding="utf-8",
            )
            (session_dir / "plan.typ").write_text("= 進め方", encoding="utf-8")
            (session_dir / "plan.pdf").write_bytes(b"pdf-plan")

            # CLI経由で export --clean を実行
            main(["export", str(session_dir), "--clean"])

            dist_dir = session_dir / "dist"
            self.assertTrue((dist_dir / "02-01_§2. 愉快なハイキング_セッションの進め方_1156回BS講習会.pdf").is_file())
            self.assertFalse((session_dir / "plan.pdf").exists())
            self.assertTrue((session_dir / "plan.typ").is_file())

    def test_init_session_toml_applies_bs_preset_and_path_inference(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            session_dir = (
                Path(tmpdir)
                / "sessions"
                / "01-BS-Koshukai"
                / "03-what-is-scouting"
                / "2026-11-08-1156th-hyogo"
            )
            session_dir.mkdir(parents=True)
            (session_dir / "slides.md").write_text(
                "header: '<span>20xx年度 指導者研修コース</span><span>§1. セッション名（担当：指導 太郎）</span>'\n"
                'footer: \'<img src="../../assets/tagline_1line.png" />\'\n'
                "# セッション名（サンプル）\n",
                encoding="utf-8",
            )

            toml_path = init_session_toml(session_dir)
            cfg = load_session_config(toml_path)

            self.assertEqual(cfg["section_no"], "03")
            self.assertEqual(cfg["session_id"], "§3")
            self.assertEqual(cfg["title"], "スカウティングって何だろう")
            self.assertEqual(cfg["session_name"], "§3. スカウティングって何だろう")
            self.assertEqual(cfg["event_short"], "1156回BS講習会")
            self.assertEqual(cfg["course_name"], "第1156回ボーイスカウト講習会")
            self.assertEqual(cfg["date"], "2026年11月8日")

            slides_text = (session_dir / "slides.md").read_text(encoding="utf-8")
            self.assertIn("第1156回ボーイスカウト講習会", slides_text)
            self.assertIn("§3. スカウティングって何だろう", slides_text)
            self.assertIn("../../../../assets/tagline_1line.png", slides_text)


if __name__ == "__main__":
    unittest.main()



