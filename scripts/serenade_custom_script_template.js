// serenade_custom_script_template.js

// --- Configuration ---
// In a real scenario, WAKE_WORD and COMMANDS_FILE_PATH would ideally be configurable
// or passed to the script. For this template, they are somewhat hardcoded
// but designed to be easily updatable.
// Serenade's scripting environment might not have direct access to host .env files.
// One common pattern is for the launching application to write a small config
// file that Serenade *can* access, or use Serenade's own settings mechanisms.
//
// These placeholders will be replaced by scripts/start-with-serenade.ps1
const WAKE_WORD = "__WAKE_WORD_PLACEHOLDER__";
const COMMANDS_FILE_PATH = "__COMMANDS_FILE_PATH_PLACEHOLDER__"; // Should be an absolute path
const POWERSHELL_SCRIPT_BRIDGE = "__POWERSHELL_SCRIPT_BRIDGE_PLACEHOLDER__"; // Should be an absolute path

// --- State ---
let listeningForCommand = false;
let commands = {};

// --- Helper Functions ---
function log(message) {
    // Check if serenade object and logMessage exist to prevent errors if run outside Serenade
    if (typeof serenade !== 'undefined' && typeof serenade.global === 'function' && typeof serenade.global().logMessage === 'function') {
        serenade.global().logMessage(`WinAssistAI: ${message}`);
    } else {
        console.log(`WinAssistAI (fallback log): ${message}`);
    }
}

// Function to load commands from the JSON file
async function loadCommands() {
    try {
        // This is a placeholder for how Serenade might read a local file.
        // The actual mechanism depends on Serenade's API, e.g., serenade.global().readFile()
        // For robustness, ensure `commands` is initialized.
        if (typeof serenade === 'undefined' || typeof serenade.global === 'undefined') {
            throw new Error("Serenade global object not available");
        }
        if (typeof serenade.global().readFile !== 'function') {
            throw new Error("Serenade readFile API not available");
        }
        const content = await serenade.global().readFile(COMMANDS_FILE_PATH);
        if (content) {
            const jsonData = JSON.parse(content);
            if (!jsonData || typeof jsonData !== 'object') {
                throw new Error("Invalid JSON format - expected object");
            }
            commands = jsonData.winassistai_commands || {};
            log(`Commands loaded successfully. Found ${Object.keys(commands).length} commands.`);
        } else {
            log(`Failed to load commands file or file is empty: ${COMMANDS_FILE_PATH}`);
            commands = {};
        }
    } catch (error) {
        log(`Error loading or parsing commands: ${error}`);
        commands = {};
    }
}

// Function to execute a PowerShell script
async function executePowerShellCommand(commandName) {
    let commandForBridge = commandName;
    let isAdhocCommand = false;

    if (commandName.startsWith("ask-ai ")) {
        log(`Identified adhoc AI command: ${commandName}`);
        isAdhocCommand = true;
        // commandForBridge is already correctly set to commandName for this case
    } else if (!commands[commandName] || !commands[commandName].script) {
        log(`Command not found in loaded commands: ${commandName}`);
        return;
    }
    // If it's a predefined command, commandForBridge is commandName (which is a key in `commands`)
    
    log(`Executing command: '${commandForBridge}' via bridge: '${POWERSHELL_SCRIPT_BRIDGE}'`);
    try {
        if (typeof serenade === 'undefined' || typeof serenade.global === 'undefined') {
            throw new Error("Serenade global object not available");
        }
        if (typeof serenade.global().execute !== 'function') {
            throw new Error("Serenade execute API not available");
        }
        
        const args = [
            '-ExecutionPolicy', 'Bypass',
            '-File', `"${POWERSHELL_SCRIPT_BRIDGE.replace(/"/g, '\\"')}"`,
            '-Command', `"${commandForBridge.replace(/"/g, '\\"').replace(/\$/g, '`$')}"`
        ];
        
        await serenade.global().execute('powershell.exe', args);
        log(`Successfully executed command: ${commandName}`);
    } catch (error) {
        log(`Error executing PowerShell command '${commandName}': ${error.message}`);
        if (typeof serenade.global().showNotification === 'function') {
            await serenade.global().showNotification(`Command failed: ${commandName}`);
        }
    }
}

// Function to play a simple sound (conceptual)
async function playSound(soundType) {
    log(`Playing sound: ${soundType}`); // Placeholder
    // Example: if (serenade && serenade.global && serenade.global().playSound) await serenade.global().playSound(soundType === "activate" ? "activate.wav" : "error.wav");
}


// --- Serenade Integration ---
// Main speech recognition handler
function setupSpeechHandler() {
    if (typeof serenade === 'undefined' || typeof serenade.global !== 'function') {
        throw new Error("Serenade global object not available");
    }
    if (typeof serenade.global().setOnRecognizedSpeech !== 'function') {
        throw new Error("Serenade setOnRecognizedSpeech API not available");
    }

    serenade.global().setOnRecognizedSpeech(async (text) => {
        if (!text?.trim()) return;
        log(`Recognized speech: "${text}"`);

        const lowerText = text.toLowerCase();
        const wakeWordLower = WAKE_WORD.toLowerCase();

        if (listeningForCommand) {
            let commandToExecute = null;
            // Option 1: Direct match from serenade-commands.json (case-insensitive)
            const directMatchKey = Object.keys(commands).find(key => key.toLowerCase() === lowerText);
            if (directMatchKey) {
                commandToExecute = directMatchKey;
            }
            // Option 2: "run <command>" pattern (if still desired)
            else if (lowerText.startsWith("run ") && commands[lowerText.substring(4)]) {
                commandToExecute = lowerText.substring(4);
            }

            if (commandToExecute) {
                await executePowerShellCommand(commandToExecute);
            } else {
                log(`No predefined command match. Routing to AI if text is present: '${text}'`);
                if (text && text.trim().length > 0) {
                    // Construct a special "command" for the bridge to indicate AI chat
                    const aiCommandString = `ask-ai ${text.replace(/"/g, '\\"').replace(/\$/g, '`$')}`;
                    await executePowerShellCommand(aiCommandString); // serenade-bridge will need to parse this
                } else {
                    log(`No text provided to route to AI.`);
                    // await playSound("error"); // Consider a sound for "command not understood and no text for AI"
                }
            }
            listeningForCommand = false; // Reset after processing one command

        } else if (lowerText.startsWith(wakeWordLower)) {
            log(`Wake word detected!`);
            
            const potentialCommandWithWakeWord = text.substring(WAKE_WORD.length).trim();
            if (potentialCommandWithWakeWord) {
                const commandKey = Object.keys(commands).find(key => key.toLowerCase() === potentialCommandWithWakeWord.toLowerCase());
                if (commandKey) {
                    log(`Command '${commandKey}' spoken directly with wake word.`);
                    await executePowerShellCommand(commandKey);
                    listeningForCommand = false; // Command executed, reset.
                } else {
                    // Not a direct command, but text is present. Route to AI.
                    log(`Wake word detected with text: '${potentialCommandWithWakeWord}'. Routing to AI.`);
                    const aiCommandString = `ask-ai ${potentialCommandWithWakeWord.replace(/"/g, '\\"').replace(/\$/g, '`$')}`;
                    await executePowerShellCommand(aiCommandString);
                    listeningForCommand = false; // AI command attempted, reset.
                }
            } else {
                 // Wake word only, listen for next utterance as command or AI query.
                 log(`Wake word detected, listening for next command/query.`);
                 listeningForCommand = true;
                 // await playSound("activate"); 
            }
        }
    });
}

// Initialization
async function initialize() {
    log(`Initializing WinAssistAI custom Serenade script...`);
    try {
        await loadCommands();
        setupSpeechHandler();
        log(`WinAssistAI custom script initialized. Wake word: '${WAKE_WORD}'. Listening for wake word.`);
        if (typeof serenade?.global?.()?.showNotification === 'function') {
            await serenade.global().showNotification(`WinAssistAI Ready. Say '${WAKE_WORD}' to activate.`);
        }
    } catch (error) {
        log(`Initialization failed: ${error.message}`);
        if (typeof serenade?.global?.()?.showNotification === 'function') {
            await serenade.global().showNotification("WinAssistAI failed to initialize");
        }
    }
}

initialize().catch(err => {
    log(`Unhandled initialization error: ${err.message}`);
});
