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

1. Visit [elevenlabs.io](https://elevenlabs.io) and create an account
2. Log in to your dashboard
3. Go to your **Profile** settings
4. Copy your **API Key**

### Step 2: Run Setup Wizard

```powershell
# Navigate to WinAssistAI directory
cd path\to\winassistai

# Run the interactive setup wizard
.\scripts\setup-elevenlabs.ps1
```

The setup wizard will:
- Test your API key
- Show available voices
- Let you select a voice
- Configure quality settings
- Test the voice system

### Step 3: Test Your Setup

```powershell
# Test the complete system
.\scripts\test-elevenlabs.ps1 -Test

# Test specific voice
.\scripts\test-elevenlabs.ps1 -Voice "Rachel"

# List all available voices
.\scripts\test-elevenlabs.ps1 -ListVoices
```

## Manual Configuration

If you prefer manual setup, edit `config/elevenlabs.json`:

```json
{
  "enabled": true,
  "apiKey": "your-api-key-here",
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
# Test your API key
.\scripts\test-elevenlabs.ps1 -Status
```
- Verify API key is correct
- Check internet connection
- Ensure ElevenLabs service is available

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

### Setup Commands
```powershell
.\scripts\setup-elevenlabs.ps1              # Interactive setup
.\scripts\setup-elevenlabs.ps1 -ApiKey KEY  # Setup with specific key
```

### Testing Commands
```powershell
.\scripts\test-elevenlabs.ps1 -Test         # Run all tests
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

- API keys are stored locally in `config/elevenlabs.json`
- Audio cache is stored in `cache/audio/`
- No audio data is transmitted except to ElevenLabs
- Configuration file should not be shared publicly

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