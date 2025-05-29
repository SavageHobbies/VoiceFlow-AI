# WinAssistAI - Voice-Controlled Windows Assistant

A comprehensive PowerShell-based voice assistant system for Windows with **Serenade voice control integration** and **ElevenLabs AI voice synthesis** that provides hands-free voice commands, high-quality text-to-speech responses, and extensive system control capabilities. Developed by Sean Sandoval.

## 🚀 Quick Start

### Universal Cross-Platform Launch (Recommended)

**Works from ANY terminal** - Git Bash, Command Prompt, PowerShell, WSL, Linux, macOS:

```bash
# Node.js launcher (most reliable)
node winassistai.js --start-full

# Python launcher (universal compatibility)
python winassistai.py --start-full

# Bash launcher (Unix-like systems)
./winassistai.sh --start-full

# NPM (if you prefer npm)
npm start -- --start-full
```

### Platform-Specific Launch Methods

#### Git Bash (MINGW64) Users 🎯
```bash
# Best solution for Git Bash
node winassistai.js --start-full

# Alternative for Git Bash
python winassistai.py --start-full
```

#### Windows Users
```cmd
REM Native Windows batch file
WinAssistAI.bat

REM Or use universal launchers
node winassistai.js --start-full
```

#### PowerShell Users
```powershell
# Direct PowerShell execution
.\scripts\start-with-serenade.ps1

# Or universal launchers
node winassistai.js --start-full
```

### Voice Commands (After Launch)
- Say: "hello computer"
- Say: "check weather"
- Say: "open calculator"
- Say: "take screenshot"

### Quick Test Commands
```bash
# Test voice functionality
node winassistai.js --test-voice

# Setup ElevenLabs AI voice (recommended)
node winassistai.js --setup-elevenlabs

# Test ElevenLabs AI voice system
node winassistai.js --test-elevenlabs

# List available AI voices
node winassistai.js --list-voices

# List all available commands
node winassistai.js --list-commands

# Show help for all options
node winassistai.js --help
```

**📋 Having terminal issues?** See our comprehensive [Terminal Compatibility Guide](TERMINAL_GUIDE.md) for detailed instructions for every terminal type.

## 📁 System Architecture

### Core Components

- **[`say.ps1`](scripts/say.ps1)** - Enhanced text-to-speech engine with ElevenLabs AI integration
- **[`say-enhanced.ps1`](scripts/say-enhanced.ps1)** - Advanced TTS system with ElevenLabs AI voice synthesis
- **[`winassistai.ps1`](scripts/winassistai.ps1)** - Main startup and help system with Serenade integration
- **[`serenade-bridge.ps1`](scripts/serenade-bridge.ps1)** - Voice control bridge for Serenade integration
- **[`start-with-serenade.ps1`](scripts/start-with-serenade.ps1)** - Complete startup with voice control
- **[`open-browser.ps1`](scripts/open-browser.ps1)** - Web browser launcher utility

### ElevenLabs AI Voice Components

- **[`setup-elevenlabs.ps1`](scripts/setup-elevenlabs.ps1)** - Interactive ElevenLabs AI voice setup wizard
- **[`test-elevenlabs.ps1`](scripts/test-elevenlabs.ps1)** - ElevenLabs voice testing and management
- **[`config/elevenlabs.json`](config/elevenlabs.json)** - ElevenLabs configuration and voice settings

### Serenade Integration Components

- **[`check-serenade.ps1`](scripts/check-serenade.ps1)** - Detect and verify Serenade installation
- **[`open-serenade.ps1`](scripts/open-serenade.ps1)** - Launch Serenade voice control
- **[`install-serenade.ps1`](scripts/install-serenade.ps1)** - Automatic Serenade installation
- **[`close-serenade.ps1`](scripts/close-serenade.ps1)** - Close Serenade application

### Script Categories

| Category | Count | Description | Examples |
|----------|-------|-------------|----------|
| 🔍 **check-*** | 30+ | System information & diagnostics | `check-weather`, `check-uptime`, `check-ram` |
| ❌ **close-*** | 40+ | Close applications & windows | `close-calculator`, `close-chrome`, `close-spotify` |
| 🚀 **open-*** | 100+ | Launch apps, websites & folders | `open-calculator`, `open-youtube`, `open-terminal` |
| 📦 **install-*** | 25+ | Install software packages | `install-discord`, `install-spotify`, `install-zoom` |
| 🎵 **play-*** | 20+ | Music & entertainment | `play-rock-music`, `play-jazz-music` |
| 🎮 **lets-play-*** | 8+ | Games & interactive content | `lets-play-tic-tac-toe`, `lets-play-wordle` |
| 💬 **Conversational** | 50+ | Greetings & responses | `hello`, `thank-you`, `good-morning` |
| ⚙️ **Utilities** | 30+ | System actions & tools | `take-screenshot`, `set-timer`, `empty-recycle-bin` |

## 🎙️ ElevenLabs AI Voice Features

### High-Quality AI Voice Synthesis
- **Natural-sounding voices** - Much more realistic than traditional TTS
- **Multiple voice personalities** - Choose from dozens of AI voices
- **Automatic fallback** - Seamless fallback to Windows TTS if needed
- **Voice customization** - Adjust stability, similarity, and style settings
- **Audio caching** - Improved performance with local audio cache

### Quick Setup
```powershell
# Interactive setup wizard
.\scripts\setup-elevenlabs.ps1

# Test your configuration
.\scripts\test-elevenlabs.ps1 -Test

# List available voices
.\scripts\test-elevenlabs.ps1 -ListVoices
```

### Voice Management
```powershell
# Test specific voice
.\scripts\test-elevenlabs.ps1 -Voice "Rachel"

# Check configuration status
.\scripts\test-elevenlabs.ps1 -Status

# Reset configuration
.\scripts\test-elevenlabs.ps1 -Reset
```

📖 **Detailed Setup Guide**: See [ELEVENLABS_SETUP.md](ELEVENLABS_SETUP.md) for complete installation and configuration instructions.

##  Command Examples

### System Information
```powershell
.\scripts\check-weather.ps1          # Get current weather with TTS
.\scripts\check-uptime.ps1           # System uptime information
.\scripts\check-ram.ps1              # Memory usage status
.\scripts\check-internet-speed.ps1   # Network speed test
```

### Application Control
```powershell
.\scripts\open-calculator.ps1        # Launch calculator
.\scripts\close-calculator.ps1       # Close calculator
.\scripts\open-spotify.ps1           # Launch Spotify
.\scripts\install-discord.ps1        # Install Discord via winget
```

### Entertainment
```powershell
.\scripts\play-rock-music.ps1        # Stream rock music
.\scripts\lets-play-wordle.ps1       # Open Wordle game
.\scripts\show-weather-radar.ps1     # Display weather radar
```

### Conversational
```powershell
.\scripts\hello.ps1                  # Friendly greeting
.\scripts\how-are-you.ps1           # Casual conversation
.\scripts\thank-you.ps1             # Polite response
.\scripts\good-night.ps1            # Evening farewell
```

## 🎤 Voice Control Features

### Serenade Integration
- **Hands-Free Control**: Use voice commands to control your computer
- **Automatic Launch**: Serenade starts automatically with Talk2Windows
- **Seamless Bridge**: Voice commands directly execute PowerShell scripts
- **792+ Voice Commands**: All WinAssistAI scripts accessible via voice

### Voice Commands Examples
```
"hello computer"          → .\scripts\hello.ps1
"check weather"           → .\scripts\check-weather.ps1
"open calculator"         → .\scripts\open-calculator.ps1
"take screenshot"         → .\scripts\take-screenshot.ps1
"thank you computer"      → .\scripts\thank-you.ps1
"empty recycle bin"       → .\scripts\empty-recycle-bin.ps1
"win assist"              → .\scripts\win_assist_ai.ps1
```

## 🔊 Text-to-Speech Features

All scripts include built-in voice responses using Windows SAPI.SPVoice:

- **Automatic TTS**: Every script provides spoken feedback
- **English Voice**: Automatically selects English voice if available
- **Error Handling**: Speaks error messages for troubleshooting
- **Response Variety**: Many scripts use random response selection
- **Serenade Integration**: Voice responses complement voice input

### TTS Implementation
```powershell
# Basic usage
& "$PSScriptRoot/say.ps1" "Hello there!"

# Error handling with TTS
try {
    # Script logic here
    & "$PSScriptRoot/say.ps1" "Operation completed successfully."
} catch {
    & "$PSScriptRoot/say.ps1" "Sorry: $($Error[0])"
}
```

## 🛠️ System Requirements

### Core Requirements
- **OS**: Windows 10/11
- **PowerShell**: 5.1 or later
- **TTS Engine**: Windows SAPI.SPVoice (built-in)
- **Internet**: Required for web-based features and Serenade download
- **Permissions**: Some scripts require administrator rights

### For Voice Control (Optional but Recommended)
- **Serenade**: Voice control system (auto-installed by WinAssistAI)
- **Microphone**: For voice input
- **Audio Output**: For voice feedback

## 📋 Installation & Setup

### Universal Cross-Platform Setup (Recommended)

1. **Clone the repository:**
   ```bash
   git clone https://github.com/SeanSandoval/win_assist_ai.git
   cd win_assist_ai
   ```

2. **Choose your launcher** (pick what you have installed):

   #### Option A: Node.js (Recommended)
   ```bash
   # Requires Node.js 12+
   node winassistai.js --start-full
   ```

   #### Option B: Python
   ```bash
   # Requires Python 3.6+
   python winassistai.py --start-full
   # or python3 winassistai.py --start-full
   ```

   #### Option C: Bash Shell
   ```bash
   # Make executable first (Unix-like systems)
   chmod +x winassistai.sh
   ./winassistai.sh --start-full
   ```

   #### Option D: NPM
   ```bash
   npm start -- --start-full
   ```

### Windows-Specific Setup

1. **Clone the repository** (same as above)

2. **Set PowerShell execution policy (if needed):**
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

3. **Launch options:**
   ```cmd
   REM Native Windows batch
   WinAssistAI.bat
   
   REM PowerShell direct
   .\scripts\start-with-serenade.ps1 -AutoInstall
   
   REM Universal launchers
   node winassistai.js --start-full
   python winassistai.py --start-full
   ```

### Git Bash Users (MINGW64)

**No PowerShell execution policy needed!** Use the universal launchers:

```bash
# Best for Git Bash
node winassistai.js --start-full

# Alternative for Git Bash
python winassistai.py --start-full

# Direct PowerShell call (fallback)
powershell.exe -ExecutionPolicy Bypass -File "./scripts/start-with-serenade.ps1"
```

### Launch Options for All Platforms

```bash
# Full startup with Serenade (recommended)
node winassistai.js --start-full

# Test voice functionality
node winassistai.js --test-voice

# List all commands
node winassistai.js --list-commands

# Force Serenade integration
node winassistai.js --with-serenade

# Disable Serenade integration
node winassistai.js --no-serenade

# Install Serenade voice control
node winassistai.js --install-serenade

# Show all options
node winassistai.js --help
```

**📚 Need detailed terminal-specific instructions?** Check out the [Terminal Compatibility Guide](TERMINAL_GUIDE.md).

## 🎛️ Command Line Options

```powershell
.\scripts\winassistai.ps1 [options]

Options:
  -Help           Show detailed help and usage
  -ListCommands   Display all available commands by category
  -TestVoice      Test text-to-speech functionality
  -Version        Show version information
  -WithSerenade   Force Serenade voice control launch
  -NoSerenade     Disable Serenade integration

.\scripts\start-with-serenade.ps1 [options]

Options:
  -AutoInstall    Automatically install Serenade if not found
  -QuietMode      Minimal console output
  -ForceReinstall Reinstall Serenade even if present
```

## 🎤 Serenade Voice Commands

### Common Voice Commands
```
"win assist"             - Launch main WinAssistAI interface
"hello computer"          - Friendly greeting
"check weather"           - Get current weather
"open calculator"         - Launch Windows calculator
"take screenshot"         - Capture screen
"check time"              - Get current time
"good morning"            - Morning greeting
"thank you computer"      - Polite acknowledgment
"empty recycle bin"       - Clean recycle bin
```

### Dynamic Commands
- Say "run [script-name]" to execute any Talk2Windows script
- All hyphenated script names work with spaces in voice commands
- Example: "run check internet speed" executes [`check-internet-speed.ps1`](scripts/check-internet-speed.ps1)
- Example: "win assist" executes [`win_assist_ai.ps1`](scripts/win_assist_ai.ps1)

## 🔧 Customization

### Adding New Scripts

1. Create a new `.ps1` file in the `scripts/` directory
2. Include the standard header with synopsis and description
3. Add TTS functionality using `say.ps1`
4. Follow the naming convention (`action-target.ps1`)

Example template:
```powershell
<#
.SYNOPSIS
    Brief description
.DESCRIPTION
    Detailed description with TTS functionality
#>

try {
    # Your script logic here
    & "$PSScriptRoot/say.ps1" "Success message"
    exit 0
} catch {
    & "$PSScriptRoot/say.ps1" "Sorry: $($Error[0])"
    exit 1
}
```

### Modifying TTS Behavior

Edit [`say.ps1`](scripts/say.ps1) to customize:
- Voice selection criteria
- Speech rate and volume
- Output logging location
- Language preferences

## 🌐 Web Integration

Many scripts integrate with online services:
- **Weather**: wttr.in API for weather data
- **News**: RSS feeds for current events
- **Maps**: Google Maps integration
- **Music**: Various streaming services
- **Social**: Direct links to platforms

## 🎮 Interactive Features

- **Games**: Tic-tac-toe, Wordle, and more
- **Timers**: Countdown and reminder systems
- **Screenshots**: Automatic capture and storage
- **System Control**: Shutdown, restart, hibernate

## 📊 Monitoring & Diagnostics

Comprehensive system monitoring capabilities:
- Hardware status (RAM, GPU, drives)
- Network connectivity and speed
- System uptime and health
- Application and service status
- Security and update status

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Add your scripts following the established patterns
4. Include TTS responses and error handling
5. Update documentation
6. Submit a pull request

## 📄 License

This project is licensed under CC0 - see the repository for details.

## 🔗 Links

- **GitHub Repository**: https://github.com/SeanSandoval/win_assist_ai.git
- **Documentation**: See individual script headers for detailed information
- **Issues**: Report bugs and request features on GitHub

## 🎉 Getting Started Examples

Try these commands to explore the system:

```powershell
# Basic interaction
.\scripts\hello.ps1
.\scripts\how-are-you.ps1

# System information
.\scripts\check-weather.ps1
.\scripts\check-uptime.ps1

# Open applications
.\scripts\open-calculator.ps1
.\scripts\open-notepad.ps1

# Entertainment
.\scripts\play-classical-music.ps1
.\scripts\lets-play-tic-tac-toe.ps1

# System utilities
.\scripts\take-screenshot.ps1
.\scripts\empty-recycle-bin.ps1
```

---

**WinAssistAI** - Making Windows more conversational, one script at a time! 🎤💻
