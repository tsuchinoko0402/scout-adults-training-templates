# ==============================================================================
# scout-trainer-template Makefile
# ボーイスカウト指導者訓練向け成果物ビルド・管理コマンド
# ==============================================================================

SESSION ?= 00-sample-session
DIR ?=

ifdef DIR
  TARGET_SESSION := $(DIR)/$(SESSION)
else
  TARGET_SESSION := $(SESSION)
endif

# 先頭に sessions/ が付いていればそのまま、なければ sessions/ を付与
ifeq ($(patsubst sessions/%,%,$(TARGET_SESSION)),$(TARGET_SESSION))
  SESSION_DIR := sessions/$(TARGET_SESSION)
else
  SESSION_DIR := $(TARGET_SESSION)
endif

THEME_CSS := templates/marp-scout-theme.css

# Marp CLI コマンドの自動検出（ローカル node_modules、PATH、nvm、または npx）
MARP ?= $(shell \
	if [ -x "./node_modules/.bin/marp" ]; then \
		echo "./node_modules/.bin/marp"; \
	elif command -v marp >/dev/null 2>&1; then \
		command -v marp; \
	elif [ -n "$$(ls $(HOME)/.nvm/versions/node/*/bin/marp 2>/dev/null)" ]; then \
		ls $(HOME)/.nvm/versions/node/*/bin/marp 2>/dev/null | tail -n 1; \
	else \
		echo "npx -y @marp-team/marp-cli"; \
	fi \
)

# Typst コマンドの自動検出
TYPST ?= $(shell command -v typst 2>/dev/null || echo "typst")

# Python コマンドの自動検出
PYTHON ?= $(shell \
	if [ -x "/opt/homebrew/bin/python3" ]; then \
		echo "/opt/homebrew/bin/python3"; \
	elif [ -x "/usr/bin/python3" ]; then \
		echo "/usr/bin/python3"; \
	else \
		command -v python3 2>/dev/null || echo "python3"; \
	fi \
)

.PHONY: help all slides slides-pdf slides-html handout plan script safety-plan docs dist preview new clean check-session assets clean-assets

# デフォルトターゲット：ヘルプ表示
help:
	@echo "ボーイスカウト指導者訓練 成果物管理コマンド一覧:"
	@echo "  make all         [DIR=<category>] SESSION=<dir>   全成果物を一括ビルドし dist/ へ正式ファイル名で整理"
	@echo "  make docs        [DIR=<category>] SESSION=<dir>   提出書類（要項・口述・配布資料・安全計画書）を一括PDF出力"
	@echo "  make dist        [DIR=<category>] SESSION=<dir>   session.toml に基づき dist/ へ正式ファイル名でコピー出力"
	@echo "  make slides      [DIR=<category>] SESSION=<dir>   指定セッションのスライド (Marp) を PDF と HTML の両方で出力"
	@echo "  make slides-pdf  [DIR=<category>] SESSION=<dir>   指定セッションのスライドを PDF 出力"
	@echo "  make slides-html [DIR=<category>] SESSION=<dir>   指定セッションのスライドを HTML 出力（ブラウザ上映用）"
	@echo "  make handout     [DIR=<category>] SESSION=<dir>   指定セッションの受講者配布資料 (Typst) を PDF 出力"
	@echo "  make plan        [DIR=<category>] SESSION=<dir>   指定セッションのセッション要項 (Typst) を PDF 出力"
	@echo "  make script      [DIR=<category>] SESSION=<dir>   指定セッションの口述要項 (Typst) を PDF 出力"
	@echo "  make safety-plan [DIR=<category>] SESSION=<dir>   指定セッションの安全計画書 (Typst) を PDF 出力"
	@echo "  make preview     [DIR=<category>] SESSION=<dir>   Marp プレビューサーバーを起動（発表者ノート付き）"
	@echo "  make new         SESSION=<dir> [PRESET=bs1..bs5]  新規セッション作成（BS講習会プリセット・パス自動判定対応）"
	@echo "  make assets                                       日本連盟公式PRツール素材（壁紙・ロゴ）を assets/ へダウンロード"
	@echo "  make clean-assets                                 ダウンロードした公式PRツール素材を assets/ から削除"
	@echo "  make clean                                        生成された PDF / HTML / dist/ を削除"
	@echo ""
	@echo "BS講習会プリセット (make new 時に PRESET 指定またはフォルダ名から自動適用):"
	@echo "  bs1 / 01-world-scouting    : §1. 世界に広がるボーイスカウト (40分)"
	@echo "  bs2 / 02-pleasant-hiking   : §2. 愉快なハイキング (170分)"
	@echo "  bs3 / 03-what-is-scouting  : §3. スカウティングって何だろう (70分)"
	@echo "  bs4 / 04-supporting-people : §4. スカウティングを支える人たち (30分)"
	@echo "  bs5 / 05-future-of-youth   : §5. 青少年の未来のために (40分)"
	@echo ""
	@echo "例:"
	@echo "  make all SESSION=00-sample-session"
	@echo "  make new SESSION=01-BS-Koshukai/02-pleasant-hiking/2026-11-08-1156th-hyogo"
	@echo "  make all SESSION=01-BS-Koshukai/02-pleasant-hiking/2026-11-08-1156th-hyogo"

# セッションディレクトリの存在確認
check-session:
	@if [ ! -d "$(SESSION_DIR)" ]; then \
		echo "エラー: セッションディレクトリ '$(SESSION_DIR)' が見つかりません。"; \
		exit 1; \
	fi

# 全成果物の一括ビルド（スライドPDF/HTML、配布資料、要項、口述、安全計画書）＋ dist/ への正式名出力
all: slides handout plan script safety-plan dist
	@echo "✓ セッション [$(TARGET_SESSION)] の全成果物ビルドおよび dist/ 整理が完了しました。"

# 所長・主任講師提出書類セット（要項・口述・配布資料・安全計画書）＋ dist/ への正式名出力
docs: plan script handout safety-plan dist
	@echo "✓ セッション [$(TARGET_SESSION)] の指導者提出書類（要項・口述・配布資料・安全計画書）のPDF生成が完了しました。"

# session.toml に基づき dist/ ディレクトリへ提出・共有用ファイル名でエクスポート
dist: check-session
	@if [ -f "$(SESSION_DIR)/session.toml" ]; then \
		$(PYTHON) scripts/session_tool.py export "$(SESSION_DIR)"; \
	fi

# Marp スライドの一括出力（PDF & HTML の両方）
slides: slides-pdf slides-html
	@echo "✓ スライド（PDF & HTML）の生成が完了しました。"

# Marp スライドの PDF 出力
slides-pdf: check-session
	@echo "▶ スライドをビルド中: $(SESSION_DIR)/slides.md -> $(SESSION_DIR)/slides.pdf"
	$(MARP) --theme-set $(THEME_CSS) --allow-local-files --html --pdf $(SESSION_DIR)/slides.md -o $(SESSION_DIR)/slides.pdf
	@echo "✓ スライド PDF 生成完了: $(SESSION_DIR)/slides.pdf"

# Marp スライドの HTML 出力（ブラウザ上映用）
slides-html: check-session
	@echo "▶ スライド HTML をビルド中: $(SESSION_DIR)/slides.md -> $(SESSION_DIR)/slides.html"
	$(MARP) --theme-set $(THEME_CSS) --allow-local-files --html $(SESSION_DIR)/slides.md -o $(SESSION_DIR)/slides.html
	@echo "✓ スライド HTML 生成完了: $(SESSION_DIR)/slides.html"

# Typst 配布資料の PDF 出力
handout: check-session
	@if [ -f "$(SESSION_DIR)/handout.typ" ]; then \
		echo "▶ 受講者配布資料をビルド中: $(SESSION_DIR)/handout.typ -> $(SESSION_DIR)/handout.pdf"; \
		$(TYPST) compile --root . $(SESSION_DIR)/handout.typ $(SESSION_DIR)/handout.pdf; \
		echo "✓ 受講者配布資料 PDF 生成完了: $(SESSION_DIR)/handout.pdf"; \
	else \
		echo "スキップ: $(SESSION_DIR)/handout.typ が見つかりません。"; \
	fi

# Typst セッション要項の PDF 出力
plan: check-session
	@if [ -f "$(SESSION_DIR)/plan.typ" ]; then \
		echo "▶ セッション要項をビルド中: $(SESSION_DIR)/plan.typ -> $(SESSION_DIR)/plan.pdf"; \
		$(TYPST) compile --root . $(SESSION_DIR)/plan.typ $(SESSION_DIR)/plan.pdf; \
		echo "✓ セッション要項 PDF 生成完了: $(SESSION_DIR)/plan.pdf"; \
	else \
		echo "スキップ: $(SESSION_DIR)/plan.typ が見つかりません。"; \
	fi

# Typst 口述要項の PDF 出力
script: check-session
	@if [ -f "$(SESSION_DIR)/script.typ" ]; then \
		echo "▶ 口述要項をビルド中: $(SESSION_DIR)/script.typ -> $(SESSION_DIR)/script.pdf"; \
		$(TYPST) compile --root . $(SESSION_DIR)/script.typ $(SESSION_DIR)/script.pdf; \
		echo "✓ 口述要項 PDF 生成完了: $(SESSION_DIR)/script.pdf"; \
	else \
		echo "スキップ: $(SESSION_DIR)/script.typ が見つかりません。"; \
	fi

# Typst 安全計画書の PDF 出力
safety-plan: check-session
	@if [ -f "$(SESSION_DIR)/safety-plan.typ" ]; then \
		echo "▶ 安全計画書をビルド中: $(SESSION_DIR)/safety-plan.typ -> $(SESSION_DIR)/safety-plan.pdf"; \
		$(TYPST) compile --root . $(SESSION_DIR)/safety-plan.typ $(SESSION_DIR)/safety-plan.pdf; \
		echo "✓ 安全計画書 PDF 生成完了: $(SESSION_DIR)/safety-plan.pdf"; \
	fi

# Marp ローカルサーバー起動（発表者ツール付きプレビュー）
preview: check-session
	@echo "▶ プレビューサーバーを起動します (Ctrl+C で終了): $(SESSION_DIR)/slides.md"
	$(MARP) --theme-set $(THEME_CSS) --allow-local-files --html --server $(SESSION_DIR)

# 新規セッションディレクトリ作成（BS講習会プリセット・パス自動推定対応）
new:
	@if [ -z "$(TARGET_SESSION)" ] || [ "$(TARGET_SESSION)" = "00-sample-session" ]; then \
		echo "エラー: 作成するセッション名を指定してください。"; \
		echo "例: make new SESSION=01-BS-Koshukai/02-pleasant-hiking/2026-11-08-1156th-hyogo"; \
		echo "    make new SESSION=01-BS-Koshukai/03-what-is-scouting/2026-11-08-1156th-hyogo PRESET=bs3"; \
		exit 1; \
	fi
	@if [ -d "$(SESSION_DIR)" ]; then \
		echo "エラー: セッション '$(SESSION_DIR)' は既に存在します。"; \
		exit 1; \
	fi
	@mkdir -p "$$(dirname $(SESSION_DIR))"
	cp -r sessions/00-sample-session $(SESSION_DIR)
	@rm -rf $(SESSION_DIR)/dist $(SESSION_DIR)/*.pdf $(SESSION_DIR)/*.html
	@$(PYTHON) scripts/session_tool.py init "$(SESSION_DIR)" \
		$(if $(PRESET),--preset "$(PRESET)",) \
		$(if $(EVENT),--event "$(EVENT)",) \
		$(if $(COURSE),--course "$(COURSE)",) \
		$(if $(TRAINER),--trainer "$(TRAINER)",)
	@echo "✓ 新しいセッション雛形を作成しました: $(SESSION_DIR)"
	@echo "  - $(SESSION_DIR)/session.toml            (セッション設定・出力ファイル名定義)"
	@echo "  - $(SESSION_DIR)/plan.md / plan.typ      (セッション要項)"
	@echo "  - $(SESSION_DIR)/script.md / script.typ  (口述要項)"
	@echo "  - $(SESSION_DIR)/slides.md               (Marpスライド)"
	@echo "  - $(SESSION_DIR)/handout.md / handout.typ(受講者配布資料)"

# 日本連盟公式 PR ツール素材の一括ダウンロード
assets:
	@echo "▶ ボーイスカウト日本連盟 公式PRツール素材をダウンロードしています..."
	@mkdir -p assets
	@curl -s -L -o assets/logo_green.png "https://www.scout.or.jp/wp-content/uploads/2025/05/communication_sq_green_rgb.png"
	@curl -s -L -o assets/logo_white.png "https://www.scout.or.jp/wp-content/uploads/2025/05/communication_sq_white_rgb.png"
	@curl -s -L -o assets/tagline.png "https://www.scout.or.jp/wp-content/uploads/2026/06/tagline_2line_rgb.png"
	@curl -s -L -o assets/tagline_1line.png "https://www.scout.or.jp/wp-content/uploads/2025/06/tagline_1line_rgb_2000_247.png"
	@curl -s -L -o assets/PCWall_BS.png "https://www.scout.or.jp/wp-content/uploads/2025/05/PCWall_1920x1080_BS.png"
	@curl -s -L -o assets/PCWall_BVS.png "https://www.scout.or.jp/wp-content/uploads/2025/11/PCWall_1920x1080_BVS.png"
	@curl -s -L -o assets/PCWall_CS.png "https://www.scout.or.jp/wp-content/uploads/2025/11/PCWall_1920x1080_CS.png"
	@curl -s -L -o assets/PCWall_VS.png "https://www.scout.or.jp/wp-content/uploads/2025/05/PCWall_1920x1080_VS.png"
	@curl -s -L -o assets/PCWall_RS.png "https://www.scout.or.jp/wp-content/uploads/2025/05/PCWall_1920x1080_RS.png"
	@echo "✓ 公式アセット（壁紙・ロゴ・タグライン）のダウンロードが完了しました: assets/"

# ダウンロードした公式素材の削除（ダミー・クリーン状態へ復元）
clean-assets:
	@echo "▶ ダウンロードした公式アセットを削除しています..."
	@rm -f assets/logo_*.png assets/tagline*.png assets/PCWall_*.png assets/PCWall_*.jpg
	@echo "✓ 公式アセットの削除が完了しました（ダミー背景に戻りました）"

# 生成物の削除
clean:
	@echo "▶ 生成済み PDF / HTML / dist/ を削除しています..."
	find sessions -type f \( -name "*.pdf" -o -name "*.html" \) -delete
	find sessions -type d -name "dist" -exec rm -rf {} +
	@echo "✓ クリーンアップ完了"
