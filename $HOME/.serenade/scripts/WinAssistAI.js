// WinAssistAI - Serenade Voice Command Integration
// This script provides voice command integration for WinAssistAI

const WAKE_WORD = "Ash";
const BRIDGE_SCRIPT = "G:\\win_assist_ai\\scripts\\serenade-bridge.ps1";

// Basic commands with wake word
serenade.global().command(`${WAKE_WORD} hello`, async (api) => {
    await api.runShell("powershell.exe", ["-ExecutionPolicy", "Bypass", "-File", BRIDGE_SCRIPT, "-Command", "hello"]);
});

serenade.global().command(`${WAKE_WORD} check weather`, async (api) => {
    await api.runShell("powershell.exe", ["-ExecutionPolicy", "Bypass", "-File", BRIDGE_SCRIPT, "-Command", "check weather"]);
});

serenade.global().command(`${WAKE_WORD} open calculator`, async (api) => {
    await api.runShell("powershell.exe", ["-ExecutionPolicy", "Bypass", "-File", BRIDGE_SCRIPT, "-Command", "open calculator"]);
});

serenade.global().command(`${WAKE_WORD} take screenshot`, async (api) => {
    await api.runShell("powershell.exe", ["-ExecutionPolicy", "Bypass", "-File", BRIDGE_SCRIPT, "-Command", "take screenshot"]);
});

serenade.global().command(`${WAKE_WORD} what time is it`, async (api) => {
    await api.runShell("powershell.exe", ["-ExecutionPolicy", "Bypass", "-File", BRIDGE_SCRIPT, "-Command", "what time is it"]);
});

serenade.global().command(`${WAKE_WORD} say hello`, async (api) => {
    await api.runShell("powershell.exe", ["-ExecutionPolicy", "Bypass", "-File", BRIDGE_SCRIPT, "-Command", "say hello"]);
});

serenade.global().command(`${WAKE_WORD} good morning`, async (api) => {
    await api.runShell("powershell.exe", ["-ExecutionPolicy", "Bypass", "-File", BRIDGE_SCRIPT, "-Command", "good morning"]);
});

serenade.global().command(`${WAKE_WORD} thank you`, async (api) => {
    await api.runShell("powershell.exe", ["-ExecutionPolicy", "Bypass", "-File", BRIDGE_SCRIPT, "-Command", "thank you"]);
});

serenade.global().command(`${WAKE_WORD} play rock music`, async (api) => {
    await api.runShell("powershell.exe", ["-ExecutionPolicy", "Bypass", "-File", BRIDGE_SCRIPT, "-Command", "play rock music"]);
});

serenade.global().command(`${WAKE_WORD} empty recycle bin`, async (api) => {
    await api.runShell("powershell.exe", ["-ExecutionPolicy", "Bypass", "-File", BRIDGE_SCRIPT, "-Command", "empty recycle bin"]);
});

// General catch-all for AI queries
serenade.global().command(`${WAKE_WORD} <%text%>`, async (api, matches) => {
    const query = matches.text;
    await api.runShell("powershell.exe", ["-ExecutionPolicy", "Bypass", "-File", BRIDGE_SCRIPT, "-Command", `ask-ai ${query}`]);
});

console.log(`WinAssistAI voice commands loaded. Wake word: ${WAKE_WORD}`);