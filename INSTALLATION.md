# WinAssistAI Installation Guide

This comprehensive guide provides step-by-step instructions for installing and setting up WinAssistAI on **any system and terminal type**.

## 🚀 Universal Cross-Platform Installation

### Prerequisites

**Core Requirements:**
- **Any Operating System**: Windows, Linux, macOS
- **At least one runtime**: Node.js 12+, Python 3.6+, or Bash shell
- **PowerShell**: Built-in on Windows, installable on Linux/macOS
- **Internet connection** for downloading Serenade and other components
- **Microphone** for voice input (optional but recommended)
- **Audio output** device for text-to-speech responses

### Quick Installation (Any Terminal)

1. **Clone the repository:**
   ```bash
   git clone https://github.com/SeanSandoval/win_assist_ai.git
   cd win_assist_ai
   ```

2. **Choose your launcher** (pick what you have):
   ```bash
   # Option A: Node.js (recommended - most reliable)
   node winassistai.js --start-full
   
   # Option B: Python (universal compatibility)
   python winassistai.py --start-full
   # or: python3 winassistai.py --start-full
   
   # Option C: Bash shell (Unix-like systems)
   chmod +x winassistai.sh
   ./winassistai.sh --start-full
   
   # Option D: Make (if available)
   make start-full
   
   # Option E: NPM
   npm start -- --start-full
   ```

3. **That's it!** The launcher will automatically:
   - Detect your environment
   - Find PowerShell
   - Install Serenade if needed
   - Launch WinAssistAI

## 📋 Terminal-Specific Installation

### Git Bash (MINGW64/MINGW32) - SOLVED! ✅

**The Problem**: Git Bash cannot directly run `.ps1` or `.bat` files.

**The Solution**: Use our universal launchers!

```bash
# Best option for Git Bash users:
node winassistai.js --start-full

# Alternative for Git Bash:
python winassistai.py --start-full

# Make-based (if make is available):
make git-bash
```

**No PowerShell execution policy issues!** The launchers handle everything automatically.

### Windows Command Prompt ✅

```cmd
REM Option A: Native batch file
WinAssistAI.bat

REM Option B: Universal launchers
node winassistai.js --start-full
python winassistai.py --start-full

REM Option C: Make
make start-full
```

### Windows PowerShell ✅

```powershell
# Traditional method (may need execution policy)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
.\scripts\start-with-serenade.ps1 -AutoInstall

# Universal launchers (no execution policy needed)
node winassistai.js --start-full
python winassistai.py --start-full
```

### WSL (Windows Subsystem for Linux) ✅

```bash
# Recommended for WSL
python3 winassistai.py --start-full

# Alternative
node winassistai.js --start-full

# Make-based
make start-full
```

### Linux Terminal ✅

**Prerequisite**: Install PowerShell Core first:
```bash
# Ubuntu/Debian
wget -q https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
sudo apt-get update
sudo apt-get install -y powershell

# CentOS/RHEL/Fedora
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo dnf install -y powershell
```

**Then launch:**
```bash
python3 winassistai.py --start-full
node winassistai.js --start-full
make start-full
```

### macOS Terminal ✅

**Prerequisite**: Install PowerShell Core:
```bash
# Using Homebrew
brew install powershell

# Using direct download
https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-macos
```

**Then launch:**
```bash
python3 winassistai.py --start-full
node winassistai.js --start-full
make start-full
```

## 🔧 Runtime Installation

### Install Node.js (Recommended)
- **Windows/macOS/Linux**: https://nodejs.org/
- **Package managers**: 
  ```bash
  # Windows (chocolatey)
  choco install nodejs
  
  # macOS (homebrew)
  brew install node
  
  # Linux (apt)
  sudo apt install nodejs npm
  ```

### Install Python
- **Windows/macOS/Linux**: https://python.org/
- **Package managers**:
  ```bash
  # Windows (chocolatey)
  choco install python
  
  # macOS (homebrew)
  brew install python
  
  # Linux (apt)
  sudo apt install python3 python3-pip
  ```

## 🎯 Installation Verification

### Test Your Installation

```bash
# Test voice functionality
node winassistai.js --test-voice
python winassistai.py --test-voice
make test-voice

# List all available commands
node winassistai.js --list-commands
python winassistai.py --list-commands
make list-commands

# Check system compatibility
make debug
```

### Verify Serenade Integration

```bash
# Install Serenade voice control
node winassistai.js --install-serenade
python winassistai.py --install-serenade
make install-serenade
```

### Test Voice Commands

After installation, try these voice commands:
- "hello computer"
- "check weather"
- "open calculator"
- "take screenshot"

## 🛠️ Makefile Quick Reference

If you have `make` available, use these convenient commands:

```bash
make help           # Show all available commands
make start-full     # Launch with full Serenade integration
make test-voice     # Test voice functionality
make setup          # Check dependencies and setup
make git-bash       # Git Bash specific launch
make windows        # Windows batch file launch
make debug          # Show system information
```

## 🌟 Traditional Windows Installation (Legacy)

For users who prefer the traditional Windows-only approach:

### Quick Setup with Voice Control (5 minutes)

1. **Download the Repository**
   ```bash
   git clone https://github.com/SeanSandoval/win_assist_ai.git
   cd win_assist_ai
   ```

2. **Set PowerShell Execution Policy** (if needed)
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

3. **Launch with Automatic Serenade Setup**
   ```powershell
   .\scripts\start-with-serenade.ps1 -AutoInstall
   ```

### Traditional Launch Methods

```powershell
# Voice Control Startup (Recommended)
.\scripts\start-with-serenade.ps1

# PowerShell Command Line
.\scripts\winassistai.ps1 -WithSerenade
.\scripts\winassistai.ps1 -NoSerenade

# Direct Script Execution
.\scripts\hello.ps1
.\scripts\check-weather.ps1
```

## ❗ Troubleshooting

### "PowerShell not found"

**For Windows:**
- PowerShell is built-in, but try: `powershell.exe -Version`
- If missing, reinstall from Microsoft Store

**For Linux/macOS:**
- Install PowerShell Core (see installation links above)
- Verify with: `pwsh -Version`

### "Node.js/Python not found"

```bash
# Check what you have
node --version      # Should show v12.0.0 or higher
python --version    # Should show 3.6.0 or higher
python3 --version   # Alternative Python command

# Install missing runtimes (see Runtime Installation above)
```

### Git Bash Path Issues

The universal launchers automatically handle Git Bash path conversion. If you still have issues:

```bash
# Use full Windows path to PowerShell
/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -ExecutionPolicy Bypass -File "./scripts/start-with-serenade.ps1"

# Or just use the universal launchers (recommended)
node winassistai.js --start-full
```

### Permission Denied (Unix systems)

```bash
# Make scripts executable
chmod +x winassistai.sh
chmod +x *.py

# Or use the setup command
make setup
```

### Serenade Installation Issues

```bash
# Force reinstall Serenade
node winassistai.js --install-serenade
python winassistai.py --install-serenade

# Check Serenade status (Windows only)
powershell.exe -ExecutionPolicy Bypass -File "./scripts/check-serenade.ps1"
```

### Voice Control Issues

**Serenade Not Installing:**
- Ensure internet connection is active
- Run as administrator if needed: Right-click PowerShell → "Run as administrator"
- Manual install: Visit https://serenade.ai/download

**Voice Commands Not Working:**
- Check microphone permissions in Windows Settings
- Verify Serenade is running: Use launcher with `--install-serenade`
- Restart Serenade through the launcher

**Microphone Not Detected:**
- Check Windows Sound settings → Recording devices
- Ensure microphone is set as default device
- Test microphone in Windows Voice Recorder

### TTS (Text-to-Speech) Not Working

**Windows**: Built-in SAPI should work automatically
**Linux**: May need additional TTS packages
**macOS**: Uses system TTS

```bash
# Test TTS directly (Windows)
powershell.exe -ExecutionPolicy Bypass -File "./scripts/say.ps1" "Hello test"
```

### PowerShell Execution Policy Error (Windows)

```powershell
# User scope (recommended)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# System scope (if needed)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine
```

## 🎛️ Advanced Configuration

### All Available Options

```bash
# Show all launcher options
node winassistai.js --help
python winassistai.py --help
./winassistai.sh --help
make help

# Launch options
--start-full         # Full Serenade integration (recommended)
--with-serenade      # Force Serenade launch
--no-serenade        # Disable Serenade
--test-voice         # Test TTS functionality
--list-commands      # Show all available commands
--install-serenade   # Install Serenade voice control
--version            # Show version info
--help               # Show help
```

### NPM Integration

```bash
# Install dependencies (optional, no external deps required)
npm install

# Launch WinAssistAI
npm start

# Launch with options (note the -- separator)
npm start -- --start-full
npm start -- --test-voice
npm start -- --help

# Use predefined npm scripts
npm run start-full
npm run test-voice
npm run list-commands
npm run with-serenade
npm run no-serenade
npm run install-serenade
npm run help
```

### Custom Script Development

1. Create new `.ps1` files in the `scripts/` directory
2. Follow the existing naming convention (`action-target.ps1`)
3. Include TTS functionality using [`say.ps1`](scripts/say.ps1)
4. Add proper error handling

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

### Creating Custom Voice Commands
1. Create a new `.ps1` file in the `scripts/` directory
2. Follow the existing script patterns
3. Include TTS responses using `say.ps1`
4. Add error handling
5. Regenerate Serenade config: Use launcher with `--install-serenade`

## 🔗 Platform-Specific Links

### PowerShell Installation
- **Linux**: https://github.com/SeanSandoval/win_assist_ai/blob/main/docs/powershell-linux.md
- **macOS**: https://github.com/SeanSandoval/win_assist_ai/blob/main/docs/powershell-macos.md

### Runtime Downloads
- **Node.js**: https://nodejs.org/
- **Python**: https://python.org/

## 💡 Pro Tips

1. **For Git Bash users**: Use `node winassistai.js` - it's the most reliable
2. **For universal compatibility**: Install Python 3.6+ - works everywhere
3. **For Windows users**: The traditional `.bat` and `.ps1` files still work
4. **For automation**: Use `make start-full` if make is available
5. **For development**: Use `make debug` to check your environment

## 🎤 Voice Command Examples

### Voice Commands (say these out loud with Serenade)
```
"hello computer"                # Friendly greeting with TTS response
"check weather"                 # Current weather with spoken report
"open calculator"               # Launch Windows calculator
"take screenshot"               # Capture and save screen
"check time"                    # Current time announcement
"thank you computer"            # Polite acknowledgment
"empty recycle bin"             # Clean recycle bin with confirmation
"good morning"                  # Morning greeting with time-appropriate response
```

## 💻 Manual Script Examples

```bash
# Using universal launchers to run specific scripts
node winassistai.js --test-voice           # Test TTS
python winassistai.py --list-commands      # List all commands

# Traditional PowerShell (Windows)
.\scripts\hello.ps1                  # "Hey! / Hello! / Hi there!"
.\scripts\how-are-you.ps1           # Various responses
.\scripts\thank-you.ps1             # "You're welcome!"
.\scripts\check-weather.ps1         # Current weather with TTS
.\scripts\check-uptime.ps1          # System uptime
.\scripts\open-calculator.ps1       # Launch calculator
.\scripts\play-rock-music.ps1       # Stream rock music
.\scripts\take-screenshot.ps1       # Save screenshot
```

## 🆘 Support

If you encounter issues:

1. **First**: Try a different launcher (Node.js vs Python vs Bash)
2. **Check**: Run `make debug` or `make setup` to verify your environment
3. **Review**: Check the [Terminal Compatibility Guide](TERMINAL_GUIDE.md)
4. **GitHub**: Open an issue with:
   - Your operating system and terminal type
   - Which launcher you tried
   - Complete error messages
   - Output of `make debug`

## 🎯 Quick Start Summary

### For Any Terminal (Universal)
1. **Clone repository**
2. **Run: `node winassistai.js --start-full`** (or Python/Bash equivalent)
3. **Say: "hello computer"**
4. **Enjoy hands-free Windows control!**

### For Traditional Windows
1. **Clone repository**
2. **Run: `.\scripts\start-with-serenade.ps1 -AutoInstall`**
3. **Say: "hello computer"**
4. **Enjoy hands-free Windows control!**

---

**🎉 Success!** Once installed, you'll have a voice-controlled Windows assistant that works from any terminal, on any platform, with any runtime. The universal launchers eliminate all the traditional PowerShell execution policy and path issues!

You can now use any of the 792+ available voice commands or run scripts manually. Start with saying "hello computer" or try `node winassistai.js --test-voice` to explore the system.