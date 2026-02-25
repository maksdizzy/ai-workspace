#!/bin/bash
set -e

echo ""
echo "🔧 Setting up AI Workspace..."
echo ""

# --- Claude Code CLI ---
echo "🤖 Installing Claude Code..."
curl -fsSL https://claude.ai/install.sh | bash

# --- NotebookLM Python API + browser deps ---
echo "📓 Installing NotebookLM..."
pip install --quiet "notebooklm-py[browser]"
echo "🌐 Installing Chromium for NotebookLM login..."
playwright install --with-deps chromium
echo "🔗 Installing NotebookLM Claude Code skills..."
notebooklm skill install

# --- Vercel Skills ---
echo "🛠️ Installing Vercel skills..."
npx skills add https://github.com/vercel-labs/skills --skill find-skills -a claude-code -y

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
