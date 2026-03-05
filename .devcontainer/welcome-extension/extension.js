const vscode = require("vscode");

const WELCOME_PANEL_KEY = "ai-workspace.welcomeDismissed";

// ─── Hide dev-focused sidebar panels ──────────────────────────
async function hideUnwantedViews(context) {
  const CLEANUP_VERSION = 3;
  const doneVersion = context.globalState.get("activityBarCleanedVersion", 0);
  if (doneVersion >= CLEANUP_VERSION) return;

  await new Promise((r) => setTimeout(r, 5000));

  const viewsToHide = [
    "workbench.view.scm",
    "workbench.view.debug",
    "workbench.view.testing",
    "workbench.view.extension.github-pull-requests",
    "workbench.view.extension.github-pull-request",
    "workbench.view.extension.references-view",
  ];

  const commands = [
    "setViewContainerVisibility",
    "vscode.setViewContainerVisibility",
    "_workbench.setViewContainerVisible",
  ];

  for (const id of viewsToHide) {
    for (const cmd of commands) {
      try {
        await vscode.commands.executeCommand(cmd, { id, visible: false });
        break;
      } catch {
        // not available — try next
      }
    }
  }

  context.globalState.update("activityBarCleanedVersion", CLEANUP_VERSION);
}

// ─── Welcome Webview Panel ────────────────────────────────────
function createWelcomePanel(context) {
  const panel = vscode.window.createWebviewPanel(
    "aiWorkspaceWelcome",
    "Welcome to AI Workspace",
    vscode.ViewColumn.One,
    { enableScripts: true },
  );

  panel.webview.html = getWelcomeHtml();

  panel.webview.onDidReceiveMessage(
    async (message) => {
      switch (message.command) {
        case "notebooklmLogin":
          vscode.commands.executeCommand("ai-workspace.notebooklmLogin");
          break;
        case "openIntegrations":
          vscode.commands.executeCommand("ai-workspace.openIntegrations");
          break;
        case "openSkills":
          vscode.commands.executeCommand("ai-workspace.openSkills");
          break;
        case "sendPrompt":
          vscode.commands.executeCommand(
            "claude-code.sendMessage",
            message.text,
          );
          break;
        case "dismiss":
          context.globalState.update(WELCOME_PANEL_KEY, true);
          panel.dispose();
          break;
      }
    },
    undefined,
    context.subscriptions,
  );

  return panel;
}

function getWelcomeHtml() {
  return `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <style>
    body {
      font-family: var(--vscode-font-family, system-ui, sans-serif);
      color: var(--vscode-foreground);
      background: var(--vscode-editor-background);
      padding: 24px 32px;
      line-height: 1.6;
      max-width: 680px;
      margin: 0 auto;
    }
    h1 { font-size: 1.8em; margin-bottom: 4px; font-weight: 600; }
    .subtitle { opacity: 0.7; margin-bottom: 24px; }
    .section { margin-bottom: 24px; }
    .section h2 { font-size: 1.1em; margin-bottom: 8px; font-weight: 600; }
    .btn-group { display: flex; gap: 8px; flex-wrap: wrap; }
    .btn {
      display: inline-flex; align-items: center; gap: 6px;
      padding: 8px 16px; border-radius: 4px; border: none;
      cursor: pointer; font-size: 13px; font-family: inherit;
      background: var(--vscode-button-background);
      color: var(--vscode-button-foreground);
    }
    .btn:hover { background: var(--vscode-button-hoverBackground); }
    .btn-secondary {
      background: var(--vscode-button-secondaryBackground);
      color: var(--vscode-button-secondaryForeground);
    }
    .btn-secondary:hover { background: var(--vscode-button-secondaryHoverBackground); }
    .prompts { list-style: none; padding: 0; }
    .prompts li {
      padding: 8px 12px; margin: 4px 0; border-radius: 4px; cursor: pointer;
      background: var(--vscode-textBlockQuote-background);
      border: 1px solid var(--vscode-textBlockQuote-border, transparent);
    }
    .prompts li:hover { background: var(--vscode-list-hoverBackground); }
    .prompts li::before { content: '> '; opacity: 0.5; }
    .dismiss {
      margin-top: 20px; display: flex; align-items: center; gap: 6px;
      opacity: 0.7; font-size: 12px;
    }
    .dismiss input { margin: 0; }
    hr { border: none; border-top: 1px solid var(--vscode-widget-border, #333); margin: 20px 0; }
  </style>
</head>
<body>
  <h1>Welcome to AI Workspace</h1>
  <p class="subtitle">Your pre-configured workspace with AI tools, research, and integrations.</p>

  <div class="section">
    <h2>Get Started</h2>
    <div class="btn-group">
      <button class="btn" onclick="send('notebooklmLogin')">Connect NotebookLM</button>
      <button class="btn btn-secondary" onclick="send('openIntegrations')">Open Integrations</button>
      <button class="btn btn-secondary" onclick="send('openSkills')">Open Skills</button>
    </div>
  </div>

  <hr>

  <div class="section">
    <h2>Try These Prompts</h2>
    <p style="opacity:0.7; font-size:13px; margin-bottom:8px;">Click to send to Claude Code:</p>
    <ul class="prompts">
      <li onclick="prompt('Create a project folder structure for my new project')">Create a project folder structure for my new project</li>
      <li onclick="prompt('Research a topic and create a summary document')">Research a topic and create a summary document</li>
      <li onclick="prompt('Help me write a professional email')">Help me write a professional email</li>
      <li onclick="prompt('Show me what tools and integrations are available')">Show me what tools and integrations are available</li>
    </ul>
  </div>

  <div class="dismiss">
    <input type="checkbox" id="dismissCheck" onchange="if(this.checked) send('dismiss')">
    <label for="dismissCheck">Don't show this again</label>
  </div>

  <script>
    const vscode = acquireVsCodeApi();
    function send(command) { vscode.postMessage({ command }); }
    function prompt(text) { vscode.postMessage({ command: 'sendPrompt', text }); }
  </script>
</body>
</html>`;
}

// ─── Activation ───────────────────────────────────────────────
function activate(context) {
  hideUnwantedViews(context);

  // Command: Connect NotebookLM — opens noVNC, runs login in hidden terminal,
  // shows status bar button + notification to confirm login
  context.subscriptions.push(
    vscode.commands.registerCommand(
      "ai-workspace.notebooklmLogin",
      async () => {
        const terminal = vscode.window.createTerminal({
          name: "NotebookLM Login",
          hideFromUser: true,
        });
        terminal.sendText("DISPLAY=:1 notebooklm login");

        await vscode.commands.executeCommand(
          "simpleBrowser.show",
          "http://localhost:6080",
        );

        // Status bar button stays visible until clicked
        const statusItem = vscode.window.createStatusBarItem(
          vscode.StatusBarAlignment.Left,
          1000,
        );
        statusItem.text = "$(check) NotebookLM: Click when logged in";
        statusItem.command = "ai-workspace.notebooklmConfirm";
        statusItem.backgroundColor = new vscode.ThemeColor(
          "statusBarItem.warningBackground",
        );
        statusItem.show();

        const confirmDisposable = vscode.commands.registerCommand(
          "ai-workspace.notebooklmConfirm",
          () => {
            terminal.sendText("");
            setTimeout(() => terminal.dispose(), 3000);
            statusItem.dispose();
            confirmDisposable.dispose();
            vscode.window.showInformationMessage(
              "NotebookLM connected! You can close the Desktop Viewer tab.",
            );
          },
        );
        context.subscriptions.push(confirmDisposable);

        vscode.window.showInformationMessage(
          "Sign in to Google in the Desktop Viewer (password: workspace). Click the status bar button when done.",
        );
      },
    ),
  );

  // Command: Open Integrations (Composio sidebar)
  context.subscriptions.push(
    vscode.commands.registerCommand(
      "ai-workspace.openIntegrations",
      async () => {
        const cmds = ["composio.focus", "workbench.view.extension.composio"];
        for (const cmd of cmds) {
          try {
            await vscode.commands.executeCommand(cmd);
            return;
          } catch {}
        }
        vscode.window.showWarningMessage(
          "Could not open Integrations panel. Click the Integrations icon in the sidebar.",
        );
      },
    ),
  );

  // Command: Open Skills marketplace
  context.subscriptions.push(
    vscode.commands.registerCommand("ai-workspace.openSkills", async () => {
      const cmds = [
        "copilotMcpView.focus",
        "workbench.view.extension.copilotMcpLauncher",
      ];
      for (const cmd of cmds) {
        try {
          await vscode.commands.executeCommand(cmd);
          return;
        } catch {}
      }
      vscode.window.showWarningMessage(
        "Could not open Skills panel. Click the Skills icon in the sidebar.",
      );
    }),
  );

  // Show welcome webview on first activation
  const dismissed = context.globalState.get(WELCOME_PANEL_KEY, false);
  if (!dismissed) {
    createWelcomePanel(context);
  }
}

function deactivate() {}

module.exports = { activate, deactivate };
