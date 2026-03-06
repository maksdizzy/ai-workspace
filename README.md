<div align="center">

<img src=".github/logo.svg" alt="AI Workspace" width="480">

**An AI-powered workspace for people who run businesses, not write code.**

Create documents, research topics, manage files, connect your tools — all through a single AI assistant that remembers your projects and gets smarter over time.

<br>

[![Open in Codespaces](https://img.shields.io/badge/Open_in-Codespaces-2ea44f?style=for-the-badge&logo=github)](https://codespaces.new/maksdizzy/ai-workspace?quickstart=1)&nbsp;&nbsp;[![Open locally in VS Code](https://img.shields.io/badge/Open_locally-VS_Code-007ACC?style=for-the-badge&logo=visualstudiocode)](#local-recommended)

</div>

---

## The Problem

Developers have AI tools that understand their projects and work autonomously. Everyone else — HR, sales, marketing, operations, founders — is stuck copy-pasting into ChatGPT, re-explaining context every session, and switching between 10 tabs to get anything done.

**AI Workspace bridges that gap.** It's a clean, simple environment where your AI assistant lives alongside your files, knows your business context, and connects to the tools you already use.

## What You Get

### AI Assistant

A powerful AI agent in the side panel that can:
- Draft emails, reports, presentations, and spreadsheets
- Organize your files and create project structures
- Answer questions about your documents
- Execute multi-step tasks autonomously

### Persistent Memory

AI Workspace includes [Claude-Mem](https://github.com/thedotmack/claude-mem) — a built-in persistent memory system that makes the AI assistant smarter over time. Unlike standard AI chats that forget everything after each session:

- **Remembers across sessions** — the assistant retains context about your projects, preferences, and past conversations
- **Learns your style** — writing tone, formatting preferences, and recurring workflows are stored and recalled automatically
- **Builds a knowledge base** — key decisions, project details, and business context accumulate into a searchable memory
- **Works transparently** — you can view, search, and manage what the assistant remembers at any time

> [!TIP]
> Claude-Mem is pre-installed and active by default. The assistant starts learning from your first interaction — no setup required.

### Deep Research

Built-in [NotebookLM](https://notebooklm.google) integration for serious research work:
- Analyze PDFs, documents, and web sources
- Generate summaries and insights
- Create research notebooks with AI-powered Q&A

### 200+ Tool Integrations

Connect the tools your team already uses — no code required:
- **Communication** — Slack, Gmail, Microsoft Teams
- **Storage** — Google Drive, Dropbox, OneDrive
- **Productivity** — Notion, Trello, Asana, Linear
- **CRM** — HubSpot, Salesforce
- **And more** via [Composio](https://composio.dev) one-click setup

### Document Skills

Create professional documents directly from chat:
- **Word** (.docx) — Reports, proposals, letters
- **Excel** (.xlsx) — Spreadsheets, data analysis
- **PowerPoint** (.pptx) — Presentations, pitch decks
- **PDF** — Formatted documents, exports

### Extensible Skills

Browse and install community skills to teach the AI new capabilities — from data analysis to content generation to workflow automation.

## Who This Is For

| Role | How AI Workspace helps |
|------|----------------------|
| **Operations / Chief of Staff** | "Prepare the weekly board update" — AI pulls data from your files and drafts the doc in your style |
| **HR Manager** | Onboarding checklists, policy Q&A, 1-on-1 prep — automated from your existing documents |
| **Sales Rep** | Pre-call briefings, CRM updates, follow-up emails — all context-aware |
| **Marketing Manager** | Blog post to social posts to newsletter — repurposed in your brand voice |
| **Founder** | One place for fundraising docs, financial models, hiring plans — AI knows the full picture |

## Getting Started

### Local (recommended)

You need three things installed on your computer:

1. **Docker Desktop** — runs the workspace in an isolated container
   - [Download for macOS](https://www.docker.com/products/docker-desktop/) · [Download for Windows](https://www.docker.com/products/docker-desktop/) · [Install on Linux](https://docs.docker.com/desktop/install/linux/)
2. **VS Code** — the editor where the workspace runs
   - [Download VS Code](https://code.visualstudio.com/)
3. **Dev Containers extension** — connects VS Code to Docker
   - [Install Dev Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)

Once everything is installed, open VS Code and press `Ctrl+Shift+P` → **Dev Containers: Clone Repository in Container Volume** → paste:

```
https://github.com/maksdizzy/ai-workspace
```

> [!NOTE]
> First launch takes 3–5 minutes while the container is built. After that, it opens instantly.

### Cloud

No installation needed — click **Open in Codespaces** at the top of this page to launch directly in your browser.

## Usage

Open the AI assistant panel and type what you need:

| Try this | What happens |
|----------|-------------|
| *"Create a project folder structure for Q2 marketing campaign"* | Organizes files and folders for you |
| *"Research [topic] and create a summary document"* | Uses NotebookLM to gather and synthesize information |
| *"Write a professional email declining the vendor proposal"* | Drafts an email you can copy and send |
| *"Create a pitch deck about our product for investors"* | Generates a PowerPoint presentation |
| *"Analyze this spreadsheet and highlight key trends"* | Reads your data and provides insights |

## Connect Your Tools

### Integrations

Click the **Composio MCPs** icon in the left sidebar to connect Google Drive, Slack, Gmail, and 200+ other tools.

### NotebookLM

NotebookLM is Google's research tool — it lets the AI deeply analyze your documents, PDFs, web links, and other sources. Once connected, you can create research notebooks, ask questions about your sources, and generate summaries, study guides, FAQs, and even audio overviews.

**One-time setup:**

1. Press `Ctrl+Shift+P` (or `Cmd+Shift+P` on Mac)
2. Run **AI Workspace: Connect NotebookLM**
3. A browser window will open — sign in with your Google account
4. Once signed in, click the **"NotebookLM: Click when logged in"** button in the status bar

**What you can do after connecting:**

| Ask the AI | What happens |
|------------|-------------|
| *"Create a notebook about competitive analysis"* | Creates a new NotebookLM notebook |
| *"Add this PDF as a source"* | Uploads a document for AI to analyze |
| *"Summarize all my sources"* | Generates a synthesis across all uploaded materials |
| *"What do my sources say about pricing strategy?"* | Answers questions grounded in your documents |
| *"Generate a briefing document from this notebook"* | Creates a formatted report based on your research |

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
| [Claude Code](https://claude.ai/claude-code) | AI assistant with autonomous task execution |
| [Claude-Mem](https://github.com/thedotmack/claude-mem) | Persistent memory — the AI remembers your projects across sessions |
| [Composio](https://composio.dev) | 200+ tool integrations (Slack, Gmail, Drive, CRM...) |
| [NotebookLM](https://notebooklm.google) | Deep research and document analysis |
| [MCP Skills](https://skills.sh) | Extensible skills marketplace |
| [Office Viewer](https://marketplace.visualstudio.com/items?itemName=cweijan.vscode-office) | View and edit Excel, Word, PowerPoint, PDF |

## Keyboard Shortcuts

| Action | Shortcut |
|--------|----------|
| Command Palette | `Ctrl+Shift+P` / `Cmd+Shift+P` |
| Toggle Sidebar | `Ctrl+B` / `Cmd+B` |
| New File | `Ctrl+N` / `Cmd+N` |
| Save | `Ctrl+S` / `Cmd+S` |

---

<div align="center">

**AI Workspace** is open source and free to use. Built for people who run businesses, not build software.

</div>
