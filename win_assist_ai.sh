#!/bin/bash
#
# WinAssistAI - Cross-Platform Launcher Script
# Compatible with Git Bash (MINGW64), WSL, and Linux terminals
#
# Usage:
#   ./win_assist_ai.sh [options]
#   bash win_assist_ai.sh [options]
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Function to print colored output
print_color() {
    printf "${1}${2}${NC}\n"
}

# Function to display banner
show_banner() {
    print_color $CYAN "
 ██╗    ██╗██╗███╗   ██╗ █████╗ ███████╗███████╗██╗███████╗████████╗ █████╗ ██╗
 ██║    ██║██║████╗  ██║██╔══██╗██╔════╝██╔════╝██║██╔════╝╚══██╔══╝██╔══██╗██║
 ██║ █╗ ██║██║██╔██╗ ██║███████║███████╗███████╗██║███████╗   ██║   ███████║██║
 ██║███╗██║██║██║╚██╗██║██╔══██║╚════██║╚════██║██║╚════██║   ██║   ██╔══██║██║
 ╚███╔███╔╝██║██║ ╚████║██║  ██║███████║███████║██║███████║   ██║   ██║  ██║██║
  ╚══╝╚══╝ ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝╚══════╝╚══════╝╚═╝╚══════╝   ╚═╝   ╚═╝  ╚═╝╚═╝

                    Voice-Controlled Windows Assistant
                    Cross-Platform Launcher for All Terminals
"
}

# Function to detect the environment
detect_environment() {
    if [[ "$OSTYPE" == "msys" || "$MSYSTEM" == "MINGW64" || "$MSYSTEM" == "MINGW32" ]]; then
        echo "git-bash"
    elif [[ -n "$WSL_DISTRO_NAME" ]]; then
        echo "wsl"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == "cygwin" ]]; then
        echo "cygwin"
    else
        echo "unknown"
    fi
}

# Function to check if PowerShell is available
check_powershell() {
    if command -v powershell.exe >/dev/null 2>&1; then
        echo "powershell.exe"
    elif command -v pwsh >/dev/null 2>&1; then
        echo "pwsh"
    elif command -v powershell >/dev/null 2>&1; then
        echo "powershell"
    else
        echo ""
    fi
}

# Function to convert path for Windows
convert_path_for_windows() {
    local path="$1"
    if [[ "$ENV_TYPE" == "git-bash" ]]; then
        # Convert /g/path to G:\path
        echo "$path" | sed 's|^/\([a-zA-Z]\)/|\1:/|' | sed 's|/|\\|g'
    elif [[ "$ENV_TYPE" == "wsl" ]]; then
        # Convert /mnt/g/path to G:\path
        echo "$path" | sed 's|^/mnt/\([a-zA-Z]\)/|\1:/|' | sed 's|/|\\|g'
    else
        echo "$path"
    fi
}

# Function to show help
show_help() {
    show_banner
    print_color $YELLOW "\nUSAGE:"
    echo "  ./win_assist_ai.sh [options]"
    echo "  bash win_assist_ai.sh [options]"
    echo ""
    print_color $YELLOW "OPTIONS:"
    echo "  -h, --help           Show this help message"
    echo "  -v, --version        Show version information"
    echo "  -t, --test-voice     Test text-to-speech functionality"
    echo "  -l, --list-commands  List all available commands"
    echo "  -s, --with-serenade  Force launch with Serenade integration"
    echo "  -n, --no-serenade    Launch without Serenade integration"
    echo "  --start-full         Launch full system with Serenade (recommended)"
    echo "  --install-serenade   Install Serenade voice control"
    echo ""
    print_color $CYAN "TERMINAL COMPATIBILITY:"
    echo "  ✓ Git Bash (MINGW64/MINGW32)"
    echo "  ✓ Windows Command Prompt"
    echo "  ✓ Windows PowerShell"
    echo "  ✓ WSL (Windows Subsystem for Linux)"
    echo "  ✓ Linux terminals"
    echo "  ✓ macOS terminals"
    echo ""
    print_color $YELLOW "EXAMPLES:"
    echo "  ./win_assist_ai.sh                    # Start with auto-detection"
    echo "  ./win_assist_ai.sh --start-full       # Full startup with Serenade"
    echo "  ./win_assist_ai.sh --test-voice       # Test voice functionality"
    echo "  ./win_assist_ai.sh --list-commands    # Show all commands"
    echo ""
}

# Function to launch PowerShell script
launch_powershell_script() {
    local script_name="$1"
    local ps_args="$2"
    local ps_cmd="$POWERSHELL_CMD"
    
    print_color $YELLOW "[LAUNCH] Starting $script_name..."
    
    if [[ "$ENV_TYPE" == "git-bash" || "$ENV_TYPE" == "cygwin" ]]; then
        # For Git Bash/Cygwin, we need to be more careful with paths
        local win_script_path=$(convert_path_for_windows "$SCRIPT_DIR/scripts/$script_name")
        print_color $BLUE "[DEBUG] Converted path: $win_script_path"
        
        if [[ -n "$ps_args" ]]; then
            "$ps_cmd" -ExecutionPolicy Bypass -File "$win_script_path" $ps_args
        else
            "$ps_cmd" -ExecutionPolicy Bypass -File "$win_script_path"
        fi
    else
        # For other environments
        if [[ -n "$ps_args" ]]; then
            "$ps_cmd" -ExecutionPolicy Bypass -File "$SCRIPT_DIR/scripts/$script_name" $ps_args
        else
            "$ps_cmd" -ExecutionPolicy Bypass -File "$SCRIPT_DIR/scripts/$script_name"
        fi
    fi
}

# Function to run a single PowerShell command
run_powershell_command() {
    local command="$1"
    local ps_cmd="$POWERSHELL_CMD"
    
    "$ps_cmd" -ExecutionPolicy Bypass -Command "$command"
}

# Main execution starts here
main() {
    # Detect environment
    ENV_TYPE=$(detect_environment)
    print_color $CYAN "[INFO] Detected environment: $ENV_TYPE"
    
    # Check for PowerShell
    POWERSHELL_CMD=$(check_powershell)
    if [[ -z "$POWERSHELL_CMD" ]]; then
        print_color $RED "[ERROR] PowerShell not found!"
        print_color $YELLOW "[HELP] Please install PowerShell:"
        echo "  • Windows: PowerShell is built-in"
        echo "  • Linux: https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-linux"
        echo "  • macOS: https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-macos"
        exit 1
    fi
    
    print_color $GREEN "[✓] PowerShell found: $POWERSHELL_CMD"
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -v|--version)
                show_banner
                run_powershell_command "Write-Host 'WinAssistAI Cross-Platform Launcher v1.0.0' -ForegroundColor Cyan"
                exit 0
                ;;
            -t|--test-voice)
                show_banner
                launch_powershell_script "win_assist_ai.ps1" "-TestVoice"
                exit 0
                ;;
            -l|--list-commands)
                show_banner
                launch_powershell_script "win_assist_ai.ps1" "-ListCommands"
                exit 0
                ;;
            -s|--with-serenade)
                WITH_SERENADE=true
                shift
                ;;
            -n|--no-serenade)
                NO_SERENADE=true
                shift
                ;;
            --start-full)
                FULL_START=true
                shift
                ;;
            --install-serenade)
                show_banner
                print_color $YELLOW "[INSTALL] Installing Serenade voice control..."
                launch_powershell_script "install-serenade.ps1" ""
                exit 0
                ;;
            *)
                print_color $RED "[ERROR] Unknown option: $1"
                echo "Use --help for usage information."
                exit 1
                ;;
        esac
    done
    
    # Default behavior
    show_banner
    print_color $GREEN "[WELCOME] Welcome to WinAssistAI!"
    print_color $BLUE "[PLATFORM] Running on: $ENV_TYPE with $POWERSHELL_CMD"
    echo ""
    
    # Launch appropriate script based on options
    if [[ "$FULL_START" == "true" ]]; then
        print_color $CYAN "[MODE] Starting full system with Serenade integration..."
        launch_powershell_script "start-with-serenade.ps1" ""
    elif [[ "$WITH_SERENADE" == "true" ]]; then
        print_color $CYAN "[MODE] Starting with Serenade integration..."
        launch_powershell_script "win_assist_ai.ps1" "-WithSerenade"
    elif [[ "$NO_SERENADE" == "true" ]]; then
        print_color $CYAN "[MODE] Starting without Serenade integration..."
        launch_powershell_script "win_assist_ai.ps1" "-NoSerenade"
    else
        print_color $CYAN "[MODE] Starting with auto-detection..."
        launch_powershell_script "win_assist_ai.ps1" ""
    fi
    
    print_color $GREEN "\n[SUCCESS] WinAssistAI launched successfully!"
    print_color $YELLOW "[TIP] Use './win_assist_ai.sh --help' for more options"
}

# Execute main function with all arguments
main "$@"