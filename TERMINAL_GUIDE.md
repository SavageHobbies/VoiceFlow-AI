# Winassistai - Terminal Compatibility Guide

This guide provides specific instructions for launching WinAssistAI from different terminal environments, solving the common issue of running PowerShell scripts from Git Bash and other terminals.

## 🚀 Quick Start for Any Terminal

### Universal Launchers (Recommended)

Win_assist_ai now includes multiple cross-platform launchers that work from any terminal:

| Launcher | Requirements | Best For |
|----------|-------------|----------|
| **Node.js** | Node.js 12+ | Most reliable, modern environments |
| **Python** | Python 3.6+ | Universal compatibility |
| **Bash** | Bash shell | Git Bash, Linux, macOS |
| **Batch** | Windows only | Command Prompt, PowerShell |

## 📋 Terminal-Specific Instructions

### 1. Git Bash (MINGW64/MINGW32) ✅

**Problem**: Git Bash cannot directly execute `.ps1` or `.bat` files.

**Solutions**:

#### Option A: Node.js Launcher (Recommended)
```bash
# Install Node.js if not already installed, then:
node win_assist_ai.js --start-full
```

#### Option B: Python Launcher
```bash
# Python 3.6+ required
python win_assist_ai.py --start-full
```

#### Option C: Bash Launcher
```bash
# Make executable (first time only)
chmod +x win_assist_ai.sh

# Run the launcher
./win_assist_ai.sh --start-full
```

#### Option D: Direct PowerShell Execution
```bash
# Launch PowerShell and run the script
powershell.exe -ExecutionPolicy Bypass -File "./scripts/start-with-serenade.ps1"
```

### 2. Windows Command Prompt ✅

```cmd
REM Option A: Use the batch file
WinAssistAI.bat

REM Option B: Node.js launcher
node win_assist_ai.js --start-full

REM Option C: Python launcher
python win_assist_ai.py --start-full

REM Option D: Direct PowerShell
powershell.exe -ExecutionPolicy Bypass -File ".\scripts\start-with-serenade.ps1"
```

### 3. Windows PowerShell ✅

```powershell
# Option A: Direct script execution
.\scripts\start-with-serenade.ps1

# Option B: Main script with Serenade
.\scripts\win_assist_ai.ps1 -WithSerenade

# Option C: Universal launchers
node win_assist_ai.js --start-full
python win_assist_ai.py --start-full
```

### 4. WSL (Windows Subsystem for Linux) ✅

```bash
# Option A: Python launcher (recommended for WSL)
python3 win_assist_ai.py --start-full

# Option B: Node.js launcher
node win_assist_ai.js --start-full

# Option C: Bash launcher
chmod +x win_assist_ai.sh
./win_assist_ai.sh --start-full

# Option D: Direct PowerShell (if PowerShell Core installed)
pwsh -ExecutionPolicy Bypass -File "./scripts/start-with-serenade.ps1"
```

### 5. Linux Terminal ✅

**Requirements**: PowerShell Core must be installed

```bash
# Option A: Python launcher
python3 win_assist_ai.py --start-full

# Option B: Node.js launcher
node win_assist_ai.js --start-full

# Option C: Bash launcher
chmod +x win_assist_ai.sh
./win_assist_ai.sh --start-full

# Option D: Direct PowerShell Core
pwsh -ExecutionPolicy Bypass -File "./scripts/start-with-serenade.ps1"
```

### 6. macOS Terminal ✅

**Requirements**: PowerShell Core must be installed

```bash
# Same as Linux - all options work
python3 win_assist_ai.py --start-full
node win_assist_ai.js --start-full
./win_assist_ai.sh --start-full
pwsh -ExecutionPolicy Bypass -File "./scripts/start-with-serenade.ps1"
```

## 🎯 Launcher Options

All universal launchers support the same command-line options:

```bash
# Show help
node win_assist_ai.js --help
python win_assist_ai.py --help
./win_assist_ai.sh --help

# Start with full Serenade integration (recommended)
node win_assist_ai.js --start-full
python win_assist_ai.py --start-full
./win_assist_ai.sh --start-full

# Test voice functionality
node win_assist_ai.js --test-voice
python win_assist_ai.py --test-voice
./win_assist_ai.sh --test-voice

# List all available commands
node win_assist_ai.js --list-commands
python win_assist_ai.py --list-commands
./win_assist_ai.sh --list-commands

# Force Serenade integration
node win_assist_ai.js --with-serenade
python win_assist_ai.py --with-serenade
./win_assist_ai.sh --with-serenade

# Disable Serenade integration
node win_assist_ai.js --no-serenade
python win_assist_ai.py --no-serenade
./win_assist_ai.sh --no-serenade

# Install Serenade voice control
node win_assist_ai.js --install-serenade
python win_assist_ai.py --install-serenade
./win_assist_ai.sh --install-serenade
```

## 📦 NPM Integration

If you prefer npm commands:

```bash
# Install dependencies (optional, no external deps required)
npm install

# Launch WinAssistAi
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

## 🔧 Troubleshooting

### Common Issues and Solutions

#### 1. "PowerShell not found" in Git Bash
```bash
# Solution: Use the full path to PowerShell
/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -ExecutionPolicy Bypass -File "./scripts/start-with-serenade.ps1"

# Or use a universal launcher
node win_assist_ai.js --start-full
```

#### 2. "Execution Policy" errors
```bash
# The universal launchers automatically handle execution policy
# Or manually set policy in PowerShell:
powershell.exe -Command "Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser"
```

#### 3. "Cannot find module" in Node.js
```bash
# Ensure you're in the correct directory
cd /path/to/win_assist_ai
node win_assist_ai.js --start-full
```

#### 4. "Permission denied" for shell scripts
```bash
# Make the script executable
chmod +x win_assist_ai.sh
./win_assist_ai.sh --start-full
```

#### 5. Path issues in different environments
The universal launchers automatically handle path conversion between different environments (Git Bash `/c/` vs Windows `C:\` paths).

## 🎯 Recommended Setup by Environment

### For Git Bash Users
1. **Best**: `node winassistai.js --start-full`
2. **Alternative**: `python winassistai.py --start-full`
3. **Fallback**: `chmod +x winassistai.sh && ./winassistai.sh --start-full`

### For Windows Users
1. **Native**: `WinAssistAI.bat`
2. **Modern**: `node winassistai.js --start-full`
3. **PowerShell**: `.\scripts\start-with-serenade.ps1`

### For WSL Users
1. **Best**: `python3 winassistai.py --start-full`
2. **Alternative**: `node winassistai.js --start-full`
3. **Advanced**: Install PowerShell Core and use direct scripts

### For Linux/macOS Users
1. **Requirement**: Install PowerShell Core first
2. **Best**: `python3 winassistai.py --start-full`
3. **Alternative**: `node winassistai.js --start-full`

## 🔗 Installation Links

### PowerShell Core (required for Linux/macOS)
- **Linux**: https://github.com/SeanSandoval/win_assist_ai/blob/main/docs/powershell-linux.md
- **macOS**: https://github.com/SeanSandoval/win_assist_ai/blob/main/docs/powershell-macos.md

### Node.js (optional, for Node.js launcher)
- **All platforms**: https://nodejs.org/

### Python (optional, for Python launcher)
- **All platforms**: https://python.org/

---

**Note**: The universal launchers (Node.js, Python, Bash) are designed to work seamlessly across all environments and automatically handle the complexities of path conversion and PowerShell execution.