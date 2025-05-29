#!/usr/bin/env node

/**
 * WinAssistAI - Cross-Platform Node.js Launcher
 * Universal launcher that works on any system with Node.js
 *
 * Usage:
 *   node win_assist_ai.js [options]
 *   npm start [-- options]
 */

const { spawn, exec } = require('child_process');
const path = require('path');
const fs = require('fs');
const os = require('os');

// Colors for console output
const colors = {
    reset: '\x1b[0m',
    red: '\x1b[31m',
    green: '\x1b[32m',
    yellow: '\x1b[33m',
    blue: '\x1b[34m',
    magenta: '\x1b[35m',
    cyan: '\x1b[36m',
    white: '\x1b[37m'
};

class WinAssistAILauncher {
    constructor() {
        this.scriptDir = __dirname;
        this.platform = this.detectPlatform();
        this.powershellCmd = null;
    }

    // Colored output functions
    log(color, message) {
        console.log(`${colors[color]}${message}${colors.reset}`);
    }

    error(message) { this.log('red', `[ERROR] ${message}`); }
    success(message) { this.log('green', `[✓] ${message}`); }
    warning(message) { this.log('yellow', `[WARNING] ${message}`); }
    info(message) { this.log('cyan', `[INFO] ${message}`); }
    debug(message) { this.log('blue', `[DEBUG] ${message}`); }

    // Display banner
    showBanner() {
        this.log('cyan', `
 ██╗    ██╗██╗███╗   ██╗ █████╗ ███████╗███████╗██╗███████╗████████╗ █████╗ ██╗
 ██║    ██║██║████╗  ██║██╔══██╗██╔════╝██╔════╝██║██╔════╝╚══██╔══╝██╔══██╗██║
 ██║ █╗ ██║██║██╔██╗ ██║███████║███████╗███████╗██║███████╗   ██║   ███████║██║
 ██║███╗██║██║██║╚██╗██║██╔══██║╚════██║╚════██║██║╚════██║   ██║   ██╔══██║██║
 ╚███╔███╔╝██║██║ ╚████║██║  ██║███████║███████║██║███████║   ██║   ██║  ██║██║
  ╚══╝╚══╝ ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝╚══════╝╚══════╝╚═╝╚══════╝   ╚═╝   ╚═╝  ╚═╝╚═╝

                    Voice-Controlled Windows Assistant
                    Node.js Cross-Platform Universal Launcher
        `);
    }

    // Detect platform and environment
    detectPlatform() {
        const platform = os.platform();
        const env = process.env;
        
        if (platform === 'win32') {
            if (env.MSYSTEM) {
                return { type: 'git-bash', name: `Git Bash (${env.MSYSTEM})` };
            } else if (env.WSL_DISTRO_NAME) {
                return { type: 'wsl', name: `WSL (${env.WSL_DISTRO_NAME})` };
            } else {
                return { type: 'windows', name: 'Windows' };
            }
        } else if (platform === 'linux') {
            if (env.WSL_DISTRO_NAME) {
                return { type: 'wsl', name: `WSL (${env.WSL_DISTRO_NAME})` };
            } else {
                return { type: 'linux', name: 'Linux' };
            }
        } else if (platform === 'darwin') {
            return { type: 'macos', name: 'macOS' };
        } else {
            return { type: 'unknown', name: platform };
        }
    }

    // Check for PowerShell availability
    async checkPowerShell() {
        const candidates = ['powershell.exe', 'pwsh', 'powershell'];
        
        for (const cmd of candidates) {
            try {
                await this.executeCommand(`${cmd} -Version`, { timeout: 5000 });
                this.powershellCmd = cmd;
                return cmd;
            } catch (error) {
                // Try next candidate
            }
        }
        return null;
    }

    // Execute a command and return a promise
    executeCommand(command, options = {}) {
        return new Promise((resolve, reject) => {
            const timeout = options.timeout || 30000;
            const cwd = options.cwd || this.scriptDir;
            
            const child = exec(command, { 
                cwd, 
                timeout,
                windowsHide: true 
            }, (error, stdout, stderr) => {
                if (error) {
                    reject({ error, stdout, stderr });
                } else {
                    resolve({ stdout, stderr });
                }
            });

            // Handle timeout
            setTimeout(() => {
                child.kill();
                reject(new Error('Command timeout'));
            }, timeout);
        });
    }

    // Launch PowerShell script
    async launchPowerShellScript(scriptName, args = []) {
        if (!this.powershellCmd) {
            throw new Error('PowerShell not available');
        }

        const scriptPath = path.join(this.scriptDir, 'scripts', scriptName);
        
        // Convert path for Windows if needed
        let winScriptPath = scriptPath;
        if (this.platform.type === 'git-bash' && path.sep === '/') {
            winScriptPath = scriptPath.replace(/\//g, '\\');
        }

        const psArgs = [
            '-ExecutionPolicy', 'Bypass',
            '-File', `"${winScriptPath}"`
        ];

        if (args.length > 0) {
            psArgs.push(...args);
        }

        this.info(`Launching ${scriptName} with ${this.powershellCmd}...`);
        this.debug(`Command: ${this.powershellCmd} ${psArgs.join(' ')}`);

        return new Promise((resolve, reject) => {
            const child = spawn(this.powershellCmd, psArgs, {
                stdio: 'inherit',
                cwd: this.scriptDir,
                windowsHide: false
            });

            child.on('close', (code) => {
                if (code === 0) {
                    resolve(code);
                } else {
                    reject(new Error(`Script exited with code ${code}`));
                }
            });

            child.on('error', (error) => {
                reject(error);
            });
        });
    }

    // Show help
    showHelp() {
        this.showBanner();
        this.log('yellow', '\nUSAGE:');
        console.log('  node win_assist_ai.js [options]');
        console.log('  npm start [-- options]');
        console.log('');
        this.log('yellow', 'OPTIONS:');
        console.log('  -h, --help           Show this help message');
        console.log('  -v, --version        Show version information');
        console.log('  -t, --test-voice     Test text-to-speech functionality');
        console.log('  --test-elevenlabs    Test ElevenLabs AI voice system');
        console.log('  --list-voices        List available ElevenLabs voices');
        console.log('  --setup-elevenlabs   Setup ElevenLabs AI voice synthesis');
        console.log('  -l, --list-commands  List all available commands');
        console.log('  -s, --with-serenade  Force launch with Serenade integration');
        console.log('  -n, --no-serenade    Launch without Serenade integration');
        console.log('  --start-full         Launch full system with Serenade (recommended)');
        console.log('  --install-serenade   Install Serenade voice control');
        console.log('');
        this.log('cyan', 'PLATFORM COMPATIBILITY:');
        console.log('  ✓ Windows (native)');
        console.log('  ✓ Git Bash (MINGW64/MINGW32)');
        console.log('  ✓ Windows Command Prompt');
        console.log('  ✓ Windows PowerShell');
        console.log('  ✓ WSL (Windows Subsystem for Linux)');
        console.log('  ✓ Linux terminals (with PowerShell Core)');
        console.log('  ✓ macOS terminals (with PowerShell Core)');
        console.log('');
        this.log('magenta', 'ELEVENLABS AI VOICE:');
        console.log('  ✓ High-quality AI voice synthesis');
        console.log('  ✓ Natural-sounding speech generation');
        console.log('  ✓ Multiple voice options and personalities');
        console.log('  ✓ Automatic fallback to Windows TTS');
        console.log('');
        this.log('yellow', 'EXAMPLES:');
        console.log('  node win_assist_ai.js                    # Start with auto-detection');
        console.log('  node win_assist_ai.js --start-full       # Full startup with Serenade');
        console.log('  node win_assist_ai.js --test-voice       # Test voice functionality');
        console.log('  node win_assist_ai.js --setup-elevenlabs # Setup AI voice');
        console.log('  node win_assist_ai.js --test-elevenlabs  # Test AI voice system');
        console.log('  npm start                                # Start via npm');
        console.log('  npm start -- --help                     # Show help via npm');
        console.log('');
    }

    // Main execution function
    async run(args) {
        try {
            // Parse arguments
            const options = this.parseArgs(args);

            if (options.help) {
                this.showHelp();
                return;
            }

            if (options.version) {
                this.showBanner();
                console.log('WinAssistAI Node.js Launcher v1.0.0');
                console.log('Node.js Version:', process.version);
                console.log('Platform:', this.platform.name);
                return;
            }

            // Display banner and platform info
            this.showBanner();
            this.success(`Welcome to WinAssistAI!`);
            this.info(`Platform: ${this.platform.name}`);
            this.info(`Node.js: ${process.version}`);

            // Check PowerShell availability
            this.info('Checking PowerShell availability...');
            const psCmd = await this.checkPowerShell();
            
            if (!psCmd) {
                this.error('PowerShell not found!');
                this.warning('Please install PowerShell:');
                console.log('  • Windows: PowerShell is built-in');
                console.log('  • Linux: https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-linux');
                console.log('  • macOS: https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-macos');
                process.exit(1);
            }

            this.success(`PowerShell found: ${psCmd}`);

            // Execute based on options
            if (options.testVoice) {
                await this.launchPowerShellScript('win_assist_ai.ps1', ['-TestVoice']);
            } else if (options.testElevenlabs) {
                this.info('Testing ElevenLabs AI voice system...');
                await this.launchPowerShellScript('test-elevenlabs.ps1', ['-Test']);
            } else if (options.listVoices) {
                this.info('Listing available ElevenLabs voices...');
                await this.launchPowerShellScript('test-elevenlabs.ps1', ['-ListVoices']);
            } else if (options.setupElevenlabs) {
                this.info('Setting up ElevenLabs AI voice synthesis...');
                await this.launchPowerShellScript('setup-elevenlabs.ps1');
            } else if (options.listCommands) {
                await this.launchPowerShellScript('win_assist_ai.ps1', ['-ListCommands']);
            } else if (options.installSerenade) {
                this.info('Installing Serenade voice control...');
                await this.launchPowerShellScript('install-serenade.ps1');
            } else if (options.startFull) {
                this.info('Starting full system with Serenade integration...');
                await this.launchPowerShellScript('start-with-serenade.ps1');
            } else if (options.withSerenade) {
                this.info('Starting with Serenade integration...');
                await this.launchPowerShellScript('win_assist_ai.ps1', ['-WithSerenade']);
            } else if (options.noSerenade) {
                this.info('Starting without Serenade integration...');
                await this.launchPowerShellScript('win_assist_ai.ps1', ['-NoSerenade']);
            } else {
                this.info('Starting with auto-detection...');
                await this.launchPowerShellScript('win_assist_ai.ps1');
            }

            this.success('WinAssistAI launched successfully!');
            this.log('yellow', 'Use "node win_assist_ai.js --help" for more options');

        } catch (error) {
            this.error(`Failed to launch WinAssistAI: ${error.message}`);
            this.debug(`Error details: ${error.stack}`);
            process.exit(1);
        }
    }

    // Parse command line arguments
    parseArgs(args) {
        const options = {};
        
        for (let i = 0; i < args.length; i++) {
            const arg = args[i];
            
            switch (arg) {
                case '-h':
                case '--help':
                    options.help = true;
                    break;
                case '-v':
                case '--version':
                    options.version = true;
                    break;
                case '-t':
                case '--test-voice':
                    options.testVoice = true;
                    break;
                case '-l':
                case '--list-commands':
                    options.listCommands = true;
                    break;
                case '-s':
                case '--with-serenade':
                    options.withSerenade = true;
                    break;
                case '-n':
                case '--no-serenade':
                    options.noSerenade = true;
                    break;
                case '--start-full':
                    options.startFull = true;
                    break;
                case '--install-serenade':
                    options.installSerenade = true;
                    break;
                case '--test-elevenlabs':
                    options.testElevenlabs = true;
                    break;
                case '--list-voices':
                    options.listVoices = true;
                    break;
                case '--setup-elevenlabs':
                    options.setupElevenlabs = true;
                    break;
                default:
                    if (arg.startsWith('-')) {
                        console.warn(`Unknown option: ${arg}`);
                    }
            }
        }
        
        return options;
    }
}

// Main execution
if (require.main === module) {
    const launcher = new WinAssistAILauncher();
    const args = process.argv.slice(2);
    launcher.run(args);
}

module.exports = WinAssistAILauncher;