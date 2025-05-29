#!/usr/bin/env python3
"""
WinAssistAI - Universal Python Launcher
Cross-platform launcher that works on any system with Python 3.6+

Usage:
    python win_assist_ai.py [options]
    python3 win_assist_ai.py [options]
"""

import sys
import os
import platform
import subprocess
import argparse
import shutil
from pathlib import Path

class Colors:
    """ANSI color codes for terminal output"""
    RESET = '\033[0m'
    RED = '\033[31m'
    GREEN = '\033[32m'
    YELLOW = '\033[33m'
    BLUE = '\033[34m'
    MAGENTA = '\033[35m'
    CYAN = '\033[36m'
    WHITE = '\033[37m'

class WinAssistAILauncher:
    def __init__(self):
        self.script_dir = Path(__file__).parent.absolute()
        self.platform_info = self.detect_platform()
        self.powershell_cmd = None
        
    def log(self, color, message):
        """Print colored message to console"""
        print(f"{color}{message}{Colors.RESET}")
        
    def error(self, message):
        self.log(Colors.RED, f"[ERROR] {message}")
        
    def success(self, message):
        self.log(Colors.GREEN, f"[✓] {message}")
        
    def warning(self, message):
        self.log(Colors.YELLOW, f"[WARNING] {message}")
        
    def info(self, message):
        self.log(Colors.CYAN, f"[INFO] {message}")
        
    def debug(self, message):
        self.log(Colors.BLUE, f"[DEBUG] {message}")

    def show_banner(self):
        """Display the WinAssistAI banner"""
        banner = """
 ██╗    ██╗██╗███╗   ██╗ █████╗ ███████╗███████╗██╗███████╗████████╗ █████╗ ██╗
 ██║    ██║██║████╗  ██║██╔══██╗██╔════╝██╔════╝██║██╔════╝╚══██╔══╝██╔══██╗██║
 ██║ █╗ ██║██║██╔██╗ ██║███████║███████╗███████╗██║███████╗   ██║   ███████║██║
 ██║███╗██║██║██║╚██╗██║██╔══██║╚════██║╚════██║██║╚════██║   ██║   ██╔══██║██║
 ╚███╔███╔╝██║██║ ╚████║██║  ██║███████║███████║██║███████║   ██║   ██║  ██║██║
  ╚══╝╚══╝ ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝╚══════╝╚══════╝╚═╝╚══════╝   ╚═╝   ╚═╝  ╚═╝╚═╝

                    Voice-Controlled Windows Assistant
                    Python Universal Cross-Platform Launcher
        """
        self.log(Colors.CYAN, banner)

    def detect_platform(self):
        """Detect the current platform and environment"""
        system = platform.system().lower()
        env = os.environ
        
        if system == 'windows':
            if 'MSYSTEM' in env:
                return {
                    'type': 'git-bash',
                    'name': f"Git Bash ({env['MSYSTEM']})",
                    'system': 'windows'
                }
            elif 'WSL_DISTRO_NAME' in env:
                return {
                    'type': 'wsl',
                    'name': f"WSL ({env['WSL_DISTRO_NAME']})",
                    'system': 'linux'
                }
            else:
                return {
                    'type': 'windows',
                    'name': 'Windows',
                    'system': 'windows'
                }
        elif system == 'linux':
            if 'WSL_DISTRO_NAME' in env:
                return {
                    'type': 'wsl',
                    'name': f"WSL ({env['WSL_DISTRO_NAME']})",
                    'system': 'linux'
                }
            else:
                return {
                    'type': 'linux',
                    'name': 'Linux',
                    'system': 'linux'
                }
        elif system == 'darwin':
            return {
                'type': 'macos',
                'name': 'macOS',
                'system': 'darwin'
            }
        else:
            return {
                'type': 'unknown',
                'name': system,
                'system': system
            }

    def check_powershell(self):
        """Check for PowerShell availability"""
        candidates = ['powershell.exe', 'pwsh', 'powershell']
        
        for cmd in candidates:
            if shutil.which(cmd):
                try:
                    # Test if the command works
                    result = subprocess.run(
                        [cmd, '-Command', 'Write-Host "Test"'],
                        capture_output=True,
                        timeout=5,
                        text=True
                    )
                    if result.returncode == 0:
                        self.powershell_cmd = cmd
                        return cmd
                except (subprocess.TimeoutExpired, subprocess.SubprocessError):
                    continue
        return None

    def launch_powershell_script(self, script_name, args=None):
        """Launch a PowerShell script with the given arguments"""
        if not self.powershell_cmd:
            raise RuntimeError("PowerShell not available")
            
        script_path = self.script_dir / 'scripts' / script_name
        
        if not script_path.exists():
            raise FileNotFoundError(f"Script not found: {script_path}")
        
        # Build PowerShell command
        ps_args = [
            self.powershell_cmd,
            '-ExecutionPolicy', 'Bypass',
            '-File', str(script_path)
        ]
        
        if args:
            ps_args.extend(args)
        
        self.info(f"Launching {script_name} with {self.powershell_cmd}...")
        self.debug(f"Command: {' '.join(ps_args)}")
        
        try:
            # Run the PowerShell script
            result = subprocess.run(
                ps_args,
                cwd=str(self.script_dir),
                timeout=300  # 5 minute timeout
            )
            return result.returncode
        except subprocess.TimeoutExpired:
            self.error("Script execution timed out")
            return 1
        except KeyboardInterrupt:
            self.warning("Script execution interrupted by user")
            return 130

    def show_help(self):
        """Display help information"""
        self.show_banner()
        
        help_text = """
USAGE:
  python win_assist_ai.py [options]
  python3 win_assist_ai.py [options]

OPTIONS:
  -h, --help           Show this help message
  -v, --version        Show version information
  -t, --test-voice     Test text-to-speech functionality
  -l, --list-commands  List all available commands
  -s, --with-serenade  Force launch with Serenade integration
  -n, --no-serenade    Launch without Serenade integration
  --start-full         Launch full system with Serenade (recommended)
  --install-serenade   Install Serenade voice control

PLATFORM COMPATIBILITY:
  ✓ Windows (all versions)
  ✓ Git Bash (MINGW64/MINGW32)
  ✓ Windows Command Prompt
  ✓ Windows PowerShell
  ✓ WSL (Windows Subsystem for Linux)
  ✓ Linux (with PowerShell Core)
  ✓ macOS (with PowerShell Core)
  ✓ Any system with Python 3.6+

EXAMPLES:
  python win_assist_ai.py                    # Start with auto-detection
  python win_assist_ai.py --start-full       # Full startup with Serenade
  python win_assist_ai.py --test-voice       # Test voice functionality
  python win_assist_ai.py --list-commands    # Show all commands
  python win_assist_ai.py --install-serenade # Install Serenade

REQUIREMENTS:
  • Python 3.6 or later
  • PowerShell (built-in on Windows, installable on Linux/macOS)
  • Internet connection (for some features)
        """
        
        print(help_text)

    def run(self, args):
        """Main execution function"""
        try:
            # Parse arguments
            parser = argparse.ArgumentParser(
                description='WinAssistAI Universal Python Launcher',
                add_help=False  # We'll handle help ourselves
            )
            
            parser.add_argument('-h', '--help', action='store_true')
            parser.add_argument('-v', '--version', action='store_true')
            parser.add_argument('-t', '--test-voice', action='store_true')
            parser.add_argument('-l', '--list-commands', action='store_true')
            parser.add_argument('-s', '--with-serenade', action='store_true')
            parser.add_argument('-n', '--no-serenade', action='store_true')
            parser.add_argument('--start-full', action='store_true')
            parser.add_argument('--install-serenade', action='store_true')
            
            options = parser.parse_args(args)
            
            if options.help:
                self.show_help()
                return 0
                
            if options.version:
                self.show_banner()
                print("WinAssistAI Python Launcher v1.0.0")
                print(f"Python Version: {sys.version}")
                print(f"Platform: {self.platform_info['name']}")
                return 0
            
            # Display banner and platform info
            self.show_banner()
            self.success("Welcome to WinAssistAI!")
            self.info(f"Platform: {self.platform_info['name']}")
            self.info(f"Python: {sys.version.split()[0]}")
            
            # Check PowerShell availability
            self.info("Checking PowerShell availability...")
            ps_cmd = self.check_powershell()
            
            if not ps_cmd:
                self.error("PowerShell not found!")
                self.warning("Please install PowerShell:")
                print("  • Windows: PowerShell is built-in")
                print("  • Linux: https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-linux")
                print("  • macOS: https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-macos")
                return 1
            
            self.success(f"PowerShell found: {ps_cmd}")
            
            # Execute based on options
            exit_code = 0
            
            if options.test_voice:
                exit_code = self.launch_powershell_script('win_assist_ai.ps1', ['-TestVoice'])
            elif options.list_commands:
                exit_code = self.launch_powershell_script('win_assist_ai.ps1', ['-ListCommands'])
            elif options.install_serenade:
                self.info('Installing Serenade voice control...')
                exit_code = self.launch_powershell_script('install-serenade.ps1')
            elif options.start_full:
                self.info('Starting full system with Serenade integration...')
                exit_code = self.launch_powershell_script('start-with-serenade.ps1')
            elif options.with_serenade:
                self.info('Starting with Serenade integration...')
                exit_code = self.launch_powershell_script('win_assist_ai.ps1', ['-WithSerenade'])
            elif options.no_serenade:
                self.info('Starting without Serenade integration...')
                exit_code = self.launch_powershell_script('win_assist_ai.ps1', ['-NoSerenade'])
            else:
                self.info('Starting with auto-detection...')
                exit_code = self.launch_powershell_script('win_assist_ai.ps1')
            
            if exit_code == 0:
                self.success('WinAssistAI launched successfully!')
                self.log(Colors.YELLOW, 'Use "python win_assist_ai.py --help" for more options')
            else:
                self.error(f'WinAssistAI exited with code {exit_code}')
            
            return exit_code
            
        except KeyboardInterrupt:
            self.warning('Operation cancelled by user')
            return 130
        except Exception as e:
            self.error(f'Failed to launch WinAssistAI: {e}')
            return 1

def main():
    """Entry point for the script"""
    launcher = WinAssistAILauncher()
    sys.exit(launcher.run(sys.argv[1:]))

if __name__ == '__main__':
    main()