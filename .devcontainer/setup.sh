#!/bin/bash
# Non-fatal: individual steps can fail without aborting the whole setup
set +e

echo ""
echo "🔧 Setting up AI Workspace..."
echo ""

# =============================================================
# 1. Fonts (no dependencies)
# =============================================================
echo "🔤 Installing Monaspace font..."
FONT_DIR="$HOME/.local/share/fonts"
mkdir -p "$FONT_DIR"
if curl -fsSL https://github.com/githubnext/monaspace/releases/latest/download/monaspace-v1.101.zip -o /tmp/monaspace.zip 2>/dev/null; then
  unzip -qo /tmp/monaspace.zip -d /tmp/monaspace
  find /tmp/monaspace -name '*.otf' -exec cp {} "$FONT_DIR/" \;
  fc-cache -f "$FONT_DIR" 2>/dev/null
  rm -rf /tmp/monaspace /tmp/monaspace.zip
  echo "  ✅ Monaspace installed"
else
  echo "  ⚠️ Monaspace download failed — terminal will use fallback monospace font"
fi

# =============================================================
# 2. Bun runtime (needed by claude-mem later)
# =============================================================
echo "⚡ Installing Bun..."
curl -fsSL https://bun.sh/install | bash
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
bun --version && echo "  ✅ Bun OK" || echo "  ⚠️ Bun install failed"

# =============================================================
# 3. Claude Code CLI
# =============================================================
echo "🤖 Installing Claude Code CLI..."
curl -fsSL https://claude.ai/install.sh | bash
export PATH="$HOME/.claude/local/bin:$PATH"
if [ -f "$HOME/.claude/local/bin/claude" ]; then
  echo "  ✅ Claude CLI OK"
else
  echo "  ⚠️ Claude CLI not found — will use VS Code extension only"
fi

# =============================================================
# 4. Python dependencies (notebooklm-py + Playwright)
# =============================================================
echo "📓 Installing NotebookLM..."
python3 -m pip install --quiet "notebooklm-py[browser]"
if python3 -c "import notebooklm" 2>/dev/null; then
  echo "  ✅ notebooklm-py installed"
else
  echo "  ⚠️ notebooklm-py install failed"
fi

echo "🌐 Installing Chromium for NotebookLM login..."
python3 -m playwright install --with-deps chromium || echo "  ⚠️ Playwright/Chromium install failed"

# =============================================================
# 5. NotebookLM skills (depends on notebooklm CLI from step 4)
# =============================================================
echo "🔗 Installing NotebookLM Claude Code skills..."
python3 -m notebooklm skill install || echo "  ⚠️ NotebookLM skills install skipped"

# =============================================================
# 6. Claude-Mem persistent memory (depends on Bun from step 2)
# =============================================================
echo "🧠 Installing Claude-Mem..."
curl -fsSL https://install.cmem.ai | bash
if [ $? -ne 0 ]; then
  echo "  ⚠️ Claude-Mem auto-install failed — install manually inside Claude Code:"
  echo "     /plugin marketplace add thedotmack/claude-mem"
fi

# =============================================================
# 7. Vercel Skills (depends on npx/node)
# =============================================================
echo "🛠️ Installing Vercel skills..."
npx --yes skills add https://github.com/vercel-labs/skills --skill find-skills -a claude-code -y || echo "  ⚠️ Vercel skills install skipped"

# =============================================================
# 8. Local .vsix extensions
# =============================================================
echo "🧩 Installing local extensions..."
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
    echo "  → $ext_id"

    rm -rf "${EXTENSIONS_DIR:?}/$ext_id"
    mv "$tmpdir/extension" "$EXTENSIONS_DIR/$ext_id"
    rm -rf "$tmpdir"
  fi
done
echo "  ✅ Extensions installed"

echo ""
echo "✅ Setup complete!"
echo ""
