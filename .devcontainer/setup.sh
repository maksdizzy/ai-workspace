#!/bin/bash
# Non-fatal: individual steps can fail without aborting the whole setup
set +e

echo ""
echo "🔧 Setting up AI Workspace..."
echo ""

# --- Monaspace font (GitHub's monospace font for terminal) ---
echo "🔤 Installing Monaspace font..."
FONT_DIR="$HOME/.local/share/fonts"
mkdir -p "$FONT_DIR"
if curl -fsSL https://github.com/githubnext/monaspace/releases/latest/download/monaspace-v1.101.zip -o /tmp/monaspace.zip 2>/dev/null; then
  unzip -qo /tmp/monaspace.zip -d /tmp/monaspace
  # Find otf files regardless of version directory name
  find /tmp/monaspace -name '*.otf' -exec cp {} "$FONT_DIR/" \;
  fc-cache -f "$FONT_DIR" 2>/dev/null
  rm -rf /tmp/monaspace /tmp/monaspace.zip
  echo "  ✅ Monaspace installed"
else
  echo "  ⚠️ Monaspace download failed — terminal will use fallback monospace font"
fi

# --- Claude Code CLI ---
echo "🤖 Installing Claude Code..."
curl -fsSL https://claude.ai/install.sh | bash
export PATH="$HOME/.claude/local/bin:$PATH"

# --- NotebookLM Python API + browser deps ---
echo "📓 Installing NotebookLM..."
pip install --quiet "notebooklm-py[browser]"
echo "🌐 Installing Chromium for NotebookLM login..."
playwright install --with-deps chromium
echo "🔗 Installing NotebookLM Claude Code skills..."
notebooklm skill install || echo "  ⚠️ NotebookLM skills install skipped"

# --- Bun (required by claude-mem) ---
echo "⚡ Installing Bun..."
curl -fsSL https://bun.sh/install | bash
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# --- Claude-Mem (persistent memory) ---
echo "🧠 Installing Claude-Mem..."
curl -fsSL https://install.cmem.ai | bash
if [ $? -ne 0 ]; then
  echo "  ⚠️ Claude-Mem auto-install failed — install manually inside Claude Code:"
  echo "     /plugin marketplace add thedotmack/claude-mem"
fi

# --- Vercel Skills ---
echo "🛠️ Installing Vercel skills..."
npx --yes skills add https://github.com/vercel-labs/skills --skill find-skills -a claude-code -y || echo "  ⚠️ Vercel skills install skipped"

# --- Install .vsix extensions (extract directly, no 'code' CLI needed) ---
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
