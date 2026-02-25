const vscode = require("vscode");
const fs = require("fs");
const path = require("path");

const HOME = process.env.HOME || "/home/vscode";
const NOTEBOOKLM_DIR = path.join(HOME, ".notebooklm");
const CRED_PATH = path.join(NOTEBOOKLM_DIR, "storage_state.json");

function isLoggedIn() {
  return fs.existsSync(CRED_PATH);
}

function isCodespaces() {
  return process.env.CODESPACES === "true";
}

// --- Codespaces: open noVNC desktop + run notebooklm login in terminal ---
async function loginViaDesktop() {
  const desktopUrl = vscode.Uri.parse("http://localhost:6080");
  await vscode.env.openExternal(desktopUrl);

  const choice = await vscode.window.showInformationMessage(
    "A desktop viewer is opening in your browser (password: workspace). " +
      'Click "Start Login" to launch Google sign-in inside that desktop.',
    "Start Login",
  );

  if (choice === "Start Login") {
    const terminal = vscode.window.createTerminal("NotebookLM Login");
    terminal.show();
    terminal.sendText("notebooklm login");
  }
}

// --- Local: guide user to login on host, then paste credentials ---
async function loginViaHost() {
  const LOGIN_CMD =
    'pip install "notebooklm-py[browser]" && playwright install chromium && notebooklm login';

  const step1 = await vscode.window.showInformationMessage(
    "Step 1: Run this command in your LOCAL terminal (outside the container) to sign in with Google.",
    { modal: true, detail: LOGIN_CMD },
    "Copy Command",
    "I already have credentials",
  );

  if (step1 === "Copy Command") {
    await vscode.env.clipboard.writeText(LOGIN_CMD);
    vscode.window.showInformationMessage(
      'Copied! Paste in your local terminal. After login, come back and click "Connect NotebookLM" again.',
    );
  } else if (step1 === "I already have credentials") {
    await importCredentials();
  }
}

// --- Import credentials from clipboard/paste ---
async function importCredentials() {
  const CAT_CMD = "cat ~/.notebooklm/storage_state.json";

  const step2 = await vscode.window.showInformationMessage(
    "Step 2: Copy your credentials. Run this in your local terminal:",
    { modal: true, detail: CAT_CMD },
    "Copy Command",
    "Paste Credentials",
  );

  if (step2 === "Copy Command") {
    await vscode.env.clipboard.writeText(CAT_CMD);
    vscode.window.showInformationMessage(
      'Copied! Run it locally, copy the output, then click "Connect NotebookLM" → "I already have credentials" → "Paste Credentials".',
    );
  } else if (step2 === "Paste Credentials") {
    await pasteCredentials();
  }
}

async function pasteCredentials() {
  const json = await vscode.window.showInputBox({
    prompt: "Paste the contents of ~/.notebooklm/storage_state.json",
    placeHolder: '{"cookies": [...]}',
    ignoreFocusOut: true,
  });

  if (!json) return;

  try {
    JSON.parse(json); // validate
    fs.mkdirSync(NOTEBOOKLM_DIR, { recursive: true });
    fs.writeFileSync(CRED_PATH, json, "utf8");
    vscode.window.showInformationMessage("NotebookLM connected successfully!");
  } catch {
    vscode.window.showErrorMessage(
      "Invalid JSON. Please copy the full contents of storage_state.json.",
    );
  }
}

function activate(context) {
  // Main login command — auto-detects environment
  context.subscriptions.push(
    vscode.commands.registerCommand(
      "ai-workspace.notebooklmLogin",
      async () => {
        if (isLoggedIn()) {
          vscode.window.showInformationMessage(
            "NotebookLM is already connected! Try: notebooklm list",
          );
          return;
        }

        if (isCodespaces()) {
          await loginViaDesktop();
        } else {
          await loginViaHost();
        }
      },
    ),
  );

  // Paste credentials command (standalone, for walkthrough)
  context.subscriptions.push(
    vscode.commands.registerCommand(
      "ai-workspace.pasteCredentials",
      pasteCredentials,
    ),
  );

  // Verify connection command
  context.subscriptions.push(
    vscode.commands.registerCommand("ai-workspace.notebooklmCheck", () => {
      if (isLoggedIn()) {
        const terminal = vscode.window.createTerminal("NotebookLM");
        terminal.show();
        terminal.sendText("notebooklm list");
      } else {
        vscode.window.showWarningMessage(
          "NotebookLM is not connected yet. Complete the login step first.",
        );
      }
    }),
  );

  // Show walkthrough on first activation
  const hasShownWelcome = context.globalState.get("hasShownWelcome", false);
  if (!hasShownWelcome) {
    vscode.commands.executeCommand(
      "workbench.action.openWalkthrough",
      "maksdizzy.ai-workspace-welcome#ai-workspace-setup",
      false,
    );
    context.globalState.update("hasShownWelcome", true);
  }
}

function deactivate() {}

module.exports = { activate, deactivate };
