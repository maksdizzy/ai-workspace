#!/bin/bash
# Non-fatal: individual steps can fail without aborting the whole setup
set +e

echo ""
echo "Setting up AI Workspace..."
echo ""

# =============================================================
# 1. Fonts (cosmetic, fast, has fallback)
# =============================================================
echo "[1/9] Installing Monaspace font..."
FONT_DIR="$HOME/.local/share/fonts"
mkdir -p "$FONT_DIR"
if curl -fsSL https://github.com/githubnext/monaspace/releases/latest/download/monaspace-v1.101.zip -o /tmp/monaspace.zip 2>/dev/null; then
  unzip -qo /tmp/monaspace.zip -d /tmp/monaspace
  find /tmp/monaspace -name '*.otf' -exec cp {} "$FONT_DIR/" \;
  fc-cache -f "$FONT_DIR" 2>/dev/null
  rm -rf /tmp/monaspace /tmp/monaspace.zip
  echo "  OK: Monaspace installed"
else
  echo "  SKIP: Monaspace download failed — terminal will use fallback font"
fi

# =============================================================
# 2. Bun runtime (needed by claude-mem)
# =============================================================
echo "[2/9] Installing Bun..."
curl -fsSL https://bun.sh/install | bash
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
bun --version && echo "  OK: Bun installed" || echo "  SKIP: Bun install failed"

# =============================================================
# 3. Claude Code CLI (core dependency)
# =============================================================
echo "[3/9] Installing Claude Code CLI..."
curl -fsSL https://claude.ai/install.sh | bash
export PATH="$HOME/.local/bin:$HOME/.claude/local/bin:$PATH"
if [ -x "$HOME/.local/bin/claude" ]; then
  echo "  OK: Claude CLI ($HOME/.local/bin/claude)"
elif [ -x "$HOME/.claude/local/bin/claude" ]; then
  echo "  OK: Claude CLI ($HOME/.claude/local/bin/claude)"
else
  echo "  SKIP: Claude CLI not found — will use VS Code extension only"
fi

# =============================================================
# 4. NotebookLM (Python library + Playwright Chromium)
# =============================================================
echo "[4/9] Installing NotebookLM..."
sudo apt-get update -qq && sudo apt-get install -y python3-pip -qq 2>/dev/null
python3 -m pip install --quiet "notebooklm-py[browser]"
if python3 -c "import notebooklm" 2>/dev/null; then
  echo "  OK: notebooklm-py installed"
else
  echo "  SKIP: notebooklm-py install failed"
fi

echo "  Installing Chromium for NotebookLM login..."
python3 -m playwright install --with-deps chromium || echo "  SKIP: Chromium install failed"

# =============================================================
# 5. NotebookLM skills for Claude Code
# =============================================================
echo "[5/9] Installing NotebookLM skills..."
PYTHON_SCRIPTS=$(python3 -c "import sysconfig; print(sysconfig.get_path('scripts'))" 2>/dev/null)
export PATH="${PYTHON_SCRIPTS}:$PATH"
if command -v notebooklm &>/dev/null; then
  notebooklm skill install || echo "  SKIP: NotebookLM skills install failed"
else
  echo "  SKIP: notebooklm CLI not found — skills install skipped"
fi

# =============================================================
# 6. Claude-Mem persistent memory
# =============================================================
echo "[6/9] Installing Claude-Mem..."
if [ -n "$CLAUDE_BIN" ]; then
  "$CLAUDE_BIN" plugin marketplace add thedotmack/claude-mem && \
  "$CLAUDE_BIN" plugin install claude-mem && \
  echo "  OK: Claude-Mem installed" || \
  echo "  SKIP: Claude-Mem install failed"
else
  echo "  SKIP: Claude CLI not available — install manually: claude plugin marketplace add thedotmack/claude-mem && claude plugin install claude-mem"
fi

# =============================================================
# 7. Vercel find-skills
# =============================================================
echo "[7/9] Installing find-skills..."
npx --yes skills add https://github.com/vercel-labs/skills --skill find-skills -a claude-code -y || echo "  SKIP: find-skills install failed"

# =============================================================
# 8. Anthropic document skills (docx, pdf, pptx, xlsx, doc-coauthoring)
# =============================================================
echo "[8/9] Installing document skills..."
npx --yes skills add https://github.com/anthropics/skills.git \
  --skill docx --skill pdf --skill pptx --skill xlsx --skill doc-coauthoring \
  -a claude-code -y || echo "  SKIP: document skills install failed"

# =============================================================
# 9. Local .vsix extensions (welcome extension)
# =============================================================
echo "[9/9] Installing local extensions..."
EXTENSIONS_DIR="$HOME/.vscode-server/extensions"
mkdir -p "$EXTENSIONS_DIR"

for vsix in .devcontainer/*.vsix; do
  if [ -f "$vsix" ]; then
    tmpdir=$(mktemp -d)
    unzip -q "$vsix" -d "$tmpdir"

    pkg_json="$tmpdir/extension/package.json"
    publisher=$(python3 -c "import json; print(json.load(open('$pkg_json'))['publisher'])")
    name=$(python3 -c "import json; print(json.load(open('$pkg_json'))['name'])")
    version=$(python3 -c "import json; print(json.load(open('$pkg_json'))['version'])")

    ext_id="${publisher}.${name}-${version}"
    echo "  -> $ext_id"

    rm -rf "${EXTENSIONS_DIR:?}/$ext_id"
    mv "$tmpdir/extension" "$EXTENSIONS_DIR/$ext_id"
    rm -rf "$tmpdir"
  fi
done
echo "  OK: Extensions installed"

echo ""
echo "Setup complete!"
echo ""
