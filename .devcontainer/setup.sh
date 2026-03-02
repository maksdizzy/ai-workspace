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
export PATH="$HOME/.local/bin:$HOME/.claude/local/bin:$PATH"
if command -v claude &>/dev/null; then
  echo "  ✅ Claude CLI OK ($(which claude))"
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
# notebooklm CLI is installed by pip into the same bin dir as python3
NOTEBOOKLM_BIN=$(python3 -c "import shutil; print(shutil.which('notebooklm') or '')" 2>/dev/null)
if [ -n "$NOTEBOOKLM_BIN" ]; then
  "$NOTEBOOKLM_BIN" skill install || echo "  ⚠️ NotebookLM skills install failed"
else
  echo "  ⚠️ notebooklm CLI not found — skills install skipped"
fi

# =============================================================
# 6. Claude-Mem persistent memory (non-interactive install)
#    The official installer requires TTY, so we replicate its
#    steps: clone → build → register plugin → create settings
# =============================================================
echo "🧠 Installing Claude-Mem..."
CMEM_MKT="$HOME/.claude/plugins/marketplaces/thedotmack"
CMEM_DATA="$HOME/.claude-mem"
CMEM_TMP=$(mktemp -d)

# 6a. Clone and build
if git clone --depth 1 https://github.com/thedotmack/claude-mem.git "$CMEM_TMP/claude-mem" 2>/dev/null; then
  cd "$CMEM_TMP/claude-mem"
  npm install --silent 2>/dev/null
  npm run build --silent 2>/dev/null

  # 6b. Copy to Claude Code plugin directory
  mkdir -p "$CMEM_MKT"
  rsync -a --delete "$CMEM_TMP/claude-mem/" "$CMEM_MKT/"
  cd "$CMEM_MKT" && npm install --silent 2>/dev/null

  # 6c. Read plugin version
  CMEM_VERSION="unknown"
  PLUGIN_JSON="$CMEM_MKT/plugin/.claude-plugin/plugin.json"
  if [ -f "$PLUGIN_JSON" ]; then
    CMEM_VERSION=$(python3 -c "import json; print(json.load(open('$PLUGIN_JSON')).get('version','unknown'))" 2>/dev/null || echo "unknown")
  fi

  # 6d. Register plugin with Claude Code
  PLUGINS_DIR="$HOME/.claude/plugins"
  mkdir -p "$PLUGINS_DIR"
  NOW=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

  # known_marketplaces.json
  python3 -c "
import json, os
path = '$PLUGINS_DIR/known_marketplaces.json'
data = json.load(open(path)) if os.path.exists(path) else {}
data['thedotmack'] = {
    'url': 'https://github.com/thedotmack/claude-mem',
    'path': '$CMEM_MKT'
}
json.dump(data, open(path, 'w'), indent=2)
"

  # installed_plugins.json (v2)
  python3 -c "
import json, os
path = '$PLUGINS_DIR/installed_plugins.json'
data = json.load(open(path)) if os.path.exists(path) else {'version': 2, 'plugins': {}}
data['plugins']['claude-mem@thedotmack'] = {
    'scope': 'user',
    'version': '$CMEM_VERSION',
    'installedAt': '$NOW',
    'updatedAt': '$NOW'
}
json.dump(data, open(path, 'w'), indent=2)
"

  # Enable plugin in Claude Code settings
  CLAUDE_SETTINGS="$HOME/.claude/settings.json"
  python3 -c "
import json, os
path = '$CLAUDE_SETTINGS'
data = json.load(open(path)) if os.path.exists(path) else {}
ep = data.get('enabledPlugins', {})
ep['claude-mem@thedotmack'] = True
data['enabledPlugins'] = ep
json.dump(data, open(path, 'w'), indent=2)
"

  # 6e. Create claude-mem default settings
  mkdir -p "$CMEM_DATA/logs"
  cat > "$CMEM_DATA/settings.json" << 'CMEM_SETTINGS'
{
  "provider": "claude",
  "auth_method": "cli",
  "model": "sonnet",
  "port": 37777,
  "log_level": "INFO",
  "chroma_enabled": true,
  "context_observations": 10
}
CMEM_SETTINGS

  echo "  ✅ Claude-Mem v$CMEM_VERSION installed"
else
  echo "  ⚠️ Claude-Mem install failed — install manually inside Claude Code:"
  echo "     /plugin marketplace add thedotmack/claude-mem"
fi
rm -rf "$CMEM_TMP"
cd "$HOME"

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
