# AI Workspace — Management Consultant

AI-powered consulting workspace. Open in VS Code → everything installs automatically → start working with Claude.

## Quick Start (2 minutes)

### Prerequisites
- [VS Code](https://code.visualstudio.com/) with [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)
- [Docker Desktop](https://www.docker.com/products/docker-desktop/)

### Setup
```bash
git clone https://github.com/YOUR/ai-workspace-consultant.git
code ai-workspace-consultant
```

VS Code will ask: **"Reopen in Container?"** → Click **Yes**.

That's it. Everything installs automatically:
- ✅ Claude Code extension
- ✅ MCP Integration Skills (200+ tool connections)
- ✅ Office file viewer (DOCX, XLSX, PPTX, PDF in VS Code)
- ✅ NotebookLM (research, audio, mind maps)
- ✅ Fathom MCP (meeting transcripts)
- ✅ Document tools (create/convert DOCX, PDF, XLSX)
- ✅ Clean UI (no terminal, no git, no debug panels)

### First-time onboarding

After the container builds, a welcome wizard runs in the terminal:

1. **NotebookLM** → Opens browser for Google sign-in (one time)
2. **Fathom** → Paste your API key ([get one here](https://fathom.video/api_settings/new))
3. **Other tools** → Use the 🔌 sidebar panel to connect Gmail, Slack, Notion, etc.

## What's Inside

```
├── .devcontainer/         ← Auto-setup (don't touch)
├── CLAUDE.md              ← AI agent rules & workflows
├── MEMORY.md              ← Long-term memory
├── clients/               ← One folder per client
├── templates/             ← Meeting notes, memos, kickoff docs
├── knowledge/frameworks/  ← Consulting frameworks reference
├── memory/                ← Daily work logs
├── .env.example           ← API keys template
└── README.md              ← This file
```

## Usage

Open Claude Code (Ctrl+Shift+P → "Claude Code") and try:

```
"Pull my meetings from this week"
"Create a new client folder for Acme Corp"
"Research the logistics industry using NotebookLM"
"Draft a recommendation memo comparing vendors X, Y, Z"
"Create a project kickoff doc"
"Summarize yesterday's meeting with the client"
```

## How It Works

### Meeting → Insights (Fathom)
```
You: "Process yesterday's meeting with Acme"
AI:  → Searches Fathom for the meeting
     → Pulls transcript + summary
     → Creates structured notes in clients/acme/meetings/
     → Extracts action items
     → Updates client README
     → Drafts follow-up email
```

### Research → Knowledge (NotebookLM)
```
You: "Research the European logistics market"
AI:  → Creates NotebookLM notebook "European Logistics"
     → Imports sources (URLs, reports)
     → Runs deep research
     → Synthesizes findings
     → Creates analysis doc in workspace
```

### Analysis → Deliverable (Office Docs)
```
You: "Create a recommendation deck for Acme comparing 3 vendors"
AI:  → Uses template (recommendation-memo.md)
     → Fills with analysis
     → Generates PPTX presentation
     → Creates supporting Excel with comparison matrix
     → Saves to clients/acme/deliverables/
```

## Customization

### Add a new template
Drop a .md file in `templates/`. Reference it in CLAUDE.md if you want the AI to use it automatically.

### Add a new client
```
"Create a new client folder for {name}" 
```
Or manually: create `clients/{name}/` with README.md.

### Add a framework
Add to `knowledge/frameworks/`. The AI will reference it when relevant.

### Modify AI behavior
Edit `CLAUDE.md` — change tone, add rules, modify workflows.

## MCP Server Reference

| Server | Purpose | Auth | Docs |
|---|---|---|---|
| fathom-video-mcp | Meeting transcripts, summaries, action items | API key | [GitHub](https://github.com/trevorwelch/fathom-video-mcp) |
| antigravity-notebooklm-mcp | Research, notebooks, knowledge synthesis, audio | Google login | [GitHub](https://github.com/jackc1111/antigravity-notebooklm-mcp) |
| doc-ops-mcp | Create/convert DOCX, XLSX, PDF, PPTX | None | [GitHub](https://github.com/Tele-AI/doc-ops-mcp) |
| mcp-ms-office-documents | Advanced Office doc creation (Docker) | None | [GitHub](https://github.com/dvejsada/mcp-ms-office-documents) |
