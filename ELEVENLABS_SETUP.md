# ElevenLabs AI Voice Integration Setup Guide

This guide will help you set up ElevenLabs AI voice synthesis with WinAssistAI for high-quality, natural-sounding voice responses.

## Overview

ElevenLabs integration provides:
- **High-quality AI voice synthesis** - Much more natural than Windows TTS
- **Multiple voice personalities** - Choose from dozens of AI voices
- **Automatic fallback** - Falls back to Windows TTS if ElevenLabs fails
- **Easy configuration** - Interactive setup wizard
- **Caching system** - Reduces API calls and improves performance

## Prerequisites

1. **ElevenLabs Account**
   - Sign up at [elevenlabs.io](https://elevenlabs.io)
   - Free tier includes 10,000 characters per month
   - Paid plans available for higher usage

2. **System Requirements**
   - Windows 10/11 with PowerShell 5.1+
   - Internet connection
   - WinAssistAI system installed

## Quick Setup

### Step 1: Get Your API Key

1. Visit [elevenlabs.io](https://elevenlabs.io) and create an account.
2. Log in to your dashboard.
3. Go to your **Profile** settings.
4. Copy your **API Key**.

### Step 2: Configure .env File

1. In the root of your WinAssistAI repository, find the file named `.env.example`.
2. Create a copy of this file and name it `.env`.
3. Open the `.env` file in a text editor.
4. Find the line `ELEVENLABS_API_KEY=YOUR_ELEVENLABS_API_KEY_HERE`.
5. Replace `YOUR_ELEVENLABS_API_KEY_HERE` with the API key you copied from the ElevenLabs dashboard.
   ```env
   # Example:
   ELEVENLABS_API_KEY=sk_abcdef1234567890abcdef12345678
   ```
6. Save the `.env` file.

**Important**: The `.env` file contains sensitive API keys. Ensure it is not committed to public repositories. The `.gitignore` file should already be configured to ignore `.env`.

### Step 3: Run Setup Wizard

Now that your API key is configured in the `.env` file, run the setup wizard:

```powershell
# Navigate to WinAssistAI directory
cd path\to\winassistai

# Run the interactive setup wizard
.\scripts\setup-elevenlabs.ps1
```

The setup wizard (default interactive mode) will automatically read the `ELEVENLABS_API_KEY` from your `.env` file. It will **not** ask you to enter the API key directly.

The interactive wizard will then proceed to:
- Test your API key (loaded from `.env`).
- List available voices from the ElevenLabs API.
- Let you select a voice.
- Allow you to configure voice quality settings (stability, similarity, style).
- Save these settings to `config/elevenlabs.json`.
- Test the voice system with your chosen configuration.

For advanced users or scripting, `setup-elevenlabs.ps1` also supports non-interactive modes to set a specific voice or list available voices. See the "Command Reference" section for details.

### Step 4: Test Your Setup

```powershell
# Test the complete system
.\scripts\test-elevenlabs.ps1 -Test

# Test specific voice
.\scripts\test-elevenlabs.ps1 -Voice "Rachel"

# List all available voices
.\scripts\test-elevenlabs.ps1 -ListVoices
```

## Manual Configuration

If you prefer manual setup, edit `config/elevenlabs.json`.
**Note on `apiKey`**: With the new `.env` based setup, the `apiKey` field in this JSON file is no longer used to store the actual key. The `setup-elevenlabs.ps1` script will set it to a placeholder like `"loaded_from_env"`. You should not paste your actual API key here. The key is exclusively read from the `.env` file by the scripts.

```json
{
  "enabled": true,
  "apiKey": "loaded_from_env", // This is a placeholder, actual key comes from .env
  "apiUrl": "https://api.elevenlabs.io/v1",
  "voice": {
    "id": "21m00Tcm4TlvDq8ikWAM",
    "name": "Rachel",
    "stability": 0.5,
    "similarityBoost": 0.75,
    "style": 0.0,
    "useSpeakerBoost": true
  },
  "model": "eleven_monolingual_v1",
  "outputFormat": "mp3_44100_128",
  "fallbackToWindows": true,
  "cacheAudio": true,
  "timeout": 30000,
  "retries": 3
}
```

## Voice Selection

ElevenLabs offers many voice options:

### Popular Voices
- **Rachel** - Clear, professional female voice
- **Adam** - Clear, professional male voice
- **Domi** - Confident, energetic female voice
- **Fin** - Friendly, warm male voice
- **Sarah** - Soft, gentle female voice

### Voice Categories
- **Premade** - High-quality, ready-to-use voices
- **Professional** - Premium voices for commercial use
- **Custom** - Your own cloned voices (if available)

## Usage

Once configured, ElevenLabs works automatically:

```powershell
# All existing scripts now use ElevenLabs automatically
.\scripts\say.ps1 "Hello, this uses ElevenLabs AI voice!"

# Use enhanced script directly
.\scripts\say-enhanced.ps1 "Direct ElevenLabs usage"

# Force specific TTS engine
.\scripts\say-enhanced.ps1 -Text "Hello" -Force elevenlabs
.\scripts\say-enhanced.ps1 -Text "Hello" -Force windows
```

## Advanced Configuration

### Voice Settings

- **Stability** (0.0-1.0): Controls voice consistency
  - Lower = more varied/expressive
  - Higher = more consistent/stable

- **Similarity Boost** (0.0-1.0): How closely to match original voice
  - Lower = more creative interpretation
  - Higher = closer to original voice

- **Style** (0.0-1.0): Amount of style to apply
  - 0.0 = neutral delivery
  - 1.0 = maximum style expression

### Performance Settings

```json
{
  "cacheAudio": true,           // Cache generated audio files
  "cacheDirectory": "cache/audio", // Where to store cache
  "timeout": 30000,            // API timeout in milliseconds
  "retries": 3,                // Number of retry attempts
  "chunkLengthSchedule": [120, 160, 250, 290] // Text chunking
}
```

## Troubleshooting

### Common Issues

#### 1. API Key Not Working
```powershell
# Test your API key (it's read from .env)
.\scripts\setup-elevenlabs.ps1 
```
The setup script now directly tests the key from `.env`. If it fails, it will report an error.
Ensure:
- Your API key in the `.env` file is correct.
- The `.env` file is in the root of the repository.
- You have an internet connection.
- The ElevenLabs service is available.

#### 2. Voice Not Playing
```powershell
# Test audio playback
.\scripts\test-elevenlabs.ps1 -Test
```
- Install FFmpeg for better audio support
- Check Windows audio settings
- Verify audio drivers are working

#### 3. Slow Performance
- Enable audio caching: `"cacheAudio": true`
- Use shorter text segments
- Check internet connection speed

#### 4. Quota Exceeded
- Check usage in ElevenLabs dashboard
- Upgrade to paid plan if needed
- Configure `fallbackToWindows: true` for automatic fallback

### Reset Configuration

```powershell
# Reset all ElevenLabs settings
.\scripts\test-elevenlabs.ps1 -Reset

# Reconfigure from scratch
.\scripts\setup-elevenlabs.ps1
```

### Debug Mode

```powershell
# Run with verbose output
.\scripts\say-enhanced.ps1 -Text "Test" -Verbose
.\scripts\test-elevenlabs.ps1 -Test -Verbose
```

## Command Reference

### `setup-elevenlabs.ps1`

This script manages the configuration for ElevenLabs Text-to-Speech. It primarily interacts with the `config/elevenlabs.json` file and uses the `ELEVENLABS_API_KEY` from your `.env` file.

**Usage Modes:**

1.  **Interactive Setup (Default)**:
    ```powershell
    .\scripts\setup-elevenlabs.ps1
    # OR explicitly:
    .\scripts\setup-elevenlabs.ps1 -Interactive
    ```
    This mode guides you through testing your API key, listing available voices, selecting a voice, and configuring voice quality settings. It's recommended for first-time setup or when you want a guided experience.

2.  **Set Specific Voice (Non-Interactive)**:
    ```powershell
    .\scripts\setup-elevenlabs.ps1 -SetVoice -VoiceID "YourVoiceIDHere" 
    # Example with optional VoiceName:
    .\scripts\setup-elevenlabs.ps1 -SetVoice -VoiceID "21m00Tcm4TlvDq8ikWAM" -VoiceName "Rachel"
    ```
    - `-SetVoice`: Switch to activate this mode.
    - `-VoiceID <string>`: (Mandatory) The ID of the ElevenLabs voice you want to set.
    - `-VoiceName <string>`: (Optional) A friendly name for the voice. If not provided, the script will attempt to fetch the name using the Voice ID, or default to "ID: YourVoiceIDHere (Name not fetched)".
    This mode will update `config/elevenlabs.json` with the specified voice, provided your API key in `.env` is valid. It will also set ElevenLabs to "enabled".

3.  **List Available Voices (Non-Interactive)**:
    ```powershell
    .\scripts\setup-elevenlabs.ps1 -ListAvailableVoices
    ```
    This mode fetches all available voices from your ElevenLabs account (using the API key in `.env`) and lists their names and IDs to the console. It will also attempt to speak the list of voice names.

4.  **Help**:
    ```powershell
    .\scripts\setup-elevenlabs.ps1 -Help
    ```
    Displays the help information for the script.

**Important Notes:**
- The old `-ApiKey` parameter has been removed. The API key is always sourced from the `ELEVENLABS_API_KEY` variable in your `.env` file.
- All modes that interact with the ElevenLabs API will first test the API key from `.env`. If the key is missing or invalid, the script will inform you and may set ElevenLabs to "disabled" in the configuration.

### `test-elevenlabs.ps1` (Legacy Test Script)
The `test-elevenlabs.ps1` script was used for some older testing functionalities. While some of its functions might still be relevant (like `-Test`), primary setup and voice configuration are now handled by `setup-elevenlabs.ps1`.
```powershell
.\scripts\test-elevenlabs.ps1 -Test         # Run some general tests
.\scripts\test-elevenlabs.ps1 -Status       # Show configuration status
.\scripts\test-elevenlabs.ps1 -ListVoices   # List available voices
.\scripts\test-elevenlabs.ps1 -Voice "Name" # Test specific voice
.\scripts\test-elevenlabs.ps1 -Reset        # Reset configuration
```

### Usage Commands
```powershell
.\scripts\say.ps1 "Text"                    # Auto-enhanced TTS
.\scripts\say-enhanced.ps1 "Text"           # Direct enhanced TTS
.\scripts\say-enhanced.ps1 -Setup           # Quick setup
.\scripts\say-enhanced.ps1 -ListVoices      # List voices
```

### Node.js Integration
```bash
# Setup ElevenLabs via Node.js launcher
node winassistai.js --setup-elevenlabs

# Test ElevenLabs via Node.js launcher
node winassistai.js --test-elevenlabs

# List voices via Node.js launcher
node winassistai.js --list-voices
```

## API Usage and Costs

### Free Tier
- **10,000 characters per month**
- All standard voices included
- Good for testing and light usage

### Paid Tiers
- **Starter**: 30,000 characters/month - $5
- **Creator**: 100,000 characters/month - $22
- **Pro**: 500,000 characters/month - $99
- **Scale**: 2M+ characters/month - $330+

### Character Usage Tips
- Average sentence: 50-100 characters
- Enable caching to avoid re-generating same content
- Use Windows TTS fallback for non-critical messages

## Security Notes

- Your ElevenLabs API key is stored in the `.env` file in the repository root. **Do not commit this file to public version control.**
- The `config/elevenlabs.json` file stores your voice preferences and other settings, but not the API key itself (it uses a placeholder).
- Audio cache is stored in `cache/audio/`.
- No audio data is transmitted except to ElevenLabs.

## Integration with WinAssistAI

ElevenLabs integrates seamlessly with all existing WinAssistAI features:

- **Voice Commands** - All Serenade voice commands use AI voice
- **System Responses** - Weather, time, system status use AI voice
- **Conversations** - Greetings and responses sound more natural
- **Notifications** - Reminders and alerts have better quality
- **Error Messages** - Even error messages sound professional

The integration maintains full backward compatibility - if ElevenLabs fails, the system automatically falls back to Windows TTS.

## Support

For issues with:
- **ElevenLabs API**: Contact ElevenLabs support
- **WinAssistAI Integration**: Check GitHub issues
- **Setup Problems**: Use the troubleshooting section above

## Next Steps

After successful setup:
1. Try different voices to find your favorite
2. Adjust voice settings for your preference
3. Enable caching for better performance
4. Consider upgrading ElevenLabs plan for higher usage
5. Explore advanced configuration options

Your WinAssistAI system now has professional-quality AI voice synthesis!