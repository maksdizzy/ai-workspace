<div align="center">

<img src="https://img.shields.io/badge/AI-Workspace-6366f1?style=for-the-badge&logo=robot&logoColor=white" alt="AI Workspace" height="48">

<p>A pre-configured, ready-to-use workspace with AI assistant, research tools, and 200+ integrations.<br>Built for non-technical users — no coding required.</p>

</div>

[![Open in Codespaces](https://img.shields.io/badge/Open_in-Codespaces-2ea44f?style=for-the-badge&logo=github)](https://codespaces.new/maksdizzy/ai-workspace?quickstart=1)&nbsp;&nbsp;[![Open locally in VS Code](https://img.shields.io/badge/Open_locally-VS_Code-007ACC?style=for-the-badge&logo=visualstudiocode)](vscode://ms-vscode-remote.remote-containers/cloneInVolume?url=https://github.com/maksdizzy/ai-workspace)

## Features

- **AI Assistant** — Claude Code in the side panel. Create documents, manage files, answer questions, write emails.
- **Research** — NotebookLM integration for deep analysis of documents, PDFs, and web sources.
- **200+ Integrations** — Connect Google Drive, Slack, Gmail, Notion, and more via the Integrations sidebar.
- **Skills Marketplace** — Extend capabilities with community-built skills.
- **Office Documents** — View and edit Excel, Word, PowerPoint, and PDF files directly in the workspace.

## Getting Started

### Local (recommended)

You need three things installed on your computer:

1. **Docker Desktop** — runs the workspace in an isolated container
   - [Download for macOS](https://www.docker.com/products/docker-desktop/) · [Download for Windows](https://www.docker.com/products/docker-desktop/) · [Install on Linux](https://docs.docker.com/desktop/install/linux/)
2. **VS Code** — the editor where the workspace runs
   - [Download VS Code](https://code.visualstudio.com/)
3. **Dev Containers extension** — connects VS Code to Docker
   - [Install Dev Containers](vscode:extension/ms-vscode-remote.remote-containers) (opens VS Code automatically)

Once everything is installed, click **Open locally in VS Code** at the top of this page.

> [!NOTE]
> First launch takes 3–5 minutes while the container is built. After that, it opens instantly.

### Cloud

No installation needed — click **Open in Codespaces** at the top of this page to launch directly in your browser.

## Usage

Open the Claude Code panel on the right and type what you need:

| Try this | What happens |
|----------|-------------|
| `Create a project folder structure for my new project` | Organizes files and folders for you |
| `Research [topic] and create a summary document` | Uses NotebookLM to gather and synthesize information |
| `Help me write a professional email about [subject]` | Drafts an email you can copy and send |
| `Show me what integrations are available` | Lists connected tools and suggests new ones |

## Connect Your Tools

### Integrations

Click the **Composio MCPs** icon in the left sidebar to connect Google Drive, Slack, Gmail, and 200+ other tools.

### NotebookLM

1. Press `Ctrl+Shift+P` (or `Cmd+Shift+P` on Mac)
2. Run **AI Workspace: Connect NotebookLM**
3. Sign in with your Google account in the browser tab that opens

### Skills

Click the **Copilot MCP** icon in the left sidebar to browse and install community skills that extend what the AI assistant can do.

Pre-installed skills:

- **docx** — Create and edit Word documents
- **pdf** — Generate PDF files
- **pptx** — Create PowerPoint presentations
- **xlsx** — Create Excel spreadsheets
- **doc-coauthoring** — Collaborative document editing
- **find-skills** — Discover and install new skills from the marketplace

## What's Inside

| Component | Purpose |
|-----------|---------|
| [Claude Code](https://claude.ai/claude-code) | AI assistant (panel mode) |
| [Composio](https://composio.dev) | 200+ tool integrations |
| [NotebookLM](https://notebooklm.google) | Research and document analysis |
| [MCP Skills](https://skills.sh) | Extensible skills marketplace |
| [Office Viewer](https://marketplace.visualstudio.com/items?itemName=cweijan.vscode-office) | Excel, Word, PDF support |

## Keyboard Shortcuts

| Action | Shortcut |
|--------|----------|
| Command Palette | `Ctrl+Shift+P` / `Cmd+Shift+P` |
| Toggle Sidebar | `Ctrl+B` / `Cmd+B` |
| New File | `Ctrl+N` / `Cmd+N` |
| Save | `Ctrl+S` / `Cmd+S` |
