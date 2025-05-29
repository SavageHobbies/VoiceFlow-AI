// WinAssistAI Serenade Configuration
module.exports = {
    commands: {
        "winassistai": {
            description: "WinAssistAI Voice Commands",
            category: "productivity",
            script: "g:\\win_assist_ai\\scripts\\serenade-bridge.ps1",
            args: ["-Command", "{0}"],
            platforms: ["windows"]
        }
    },
    plugins: [
        {
            name: "winassistai-commands",
            description: "WinAssistAI Command Integration",
            script: "g:\\win_assist_ai\\scripts\\serenade-bridge.ps1",
            args: ["-Command", "{0}"],
            platforms: ["windows"]
        }
    ]
}