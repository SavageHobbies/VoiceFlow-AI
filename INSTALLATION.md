# 🚀 VoiceFlow AI - Complete Installation Guide

This guide will get you up and running with VoiceFlow AI in under 10 minutes!

## 📋 Prerequisites

### **System Requirements**
- ✅ **Windows 10/11** (64-bit)
- ✅ **PowerShell 5.1+** (pre-installed on Windows)
- ✅ **Microphone** (built-in or external)
- ✅ **Speakers/Headphones** for voice output
- ✅ **Internet connection** for AI features

### **Optional Enhancements**
- 🎤 **OpenAI API Key** - For advanced AI conversations
- 🎵 **ElevenLabs API Key** - For premium voice quality

## ⚡ Quick Installation (5 minutes)

### **Method 1: Download & Run** (Recommended)

1. **Download VoiceFlow AI**
   ```powershell
   # Option A: Download ZIP from GitHub
   # Go to: https://github.com/SavageHobbies/VoiceFlow-AI
   # Click "Code" → "Download ZIP" → Extract to desired folder
   
   # Option B: Clone with Git (if you have Git installed)
   git clone https://github.com/yourusername/voiceflow-ai.git
   cd voiceflow-ai
   ```

2. **Run the Setup**
   ```powershell
   # Right-click on the folder → "Open in Terminal" or PowerShell
   .\START.ps1
   ```

3. **First-Time Configuration** (2 minutes)
   - The setup wizard will automatically start
   - Follow the prompts to configure your preferences
   - Test your microphone and speakers

4. **Start Your First Conversation**
   ```
   Say: "Ash hello"
   ```

**That's it! You're ready to go! 🎉**

---

## 🔧 Detailed Installation

### **Step 1: Download VoiceFlow AI**

#### **Option A: GitHub Download (No Git Required)**
1. Go to the [VoiceFlow AI repository](https://github.com/SavageHobbies/VoiceFlow-AI)
2. Click the green **"Code"** button
3. Select **"Download ZIP"**
4. Extract the ZIP file to your desired location (e.g., `C:\VoiceFlowAI\`)

#### **Option B: Git Clone (Recommended for Developers)**
```powershell
# Open PowerShell and navigate to where you want to install
cd C:\
git clone https://github.com/SavageHobbies/VoiceFlow-AI.git
cd VoiceFlow-AI
```

### **Step 2: Initial Setup**

1. **Open PowerShell in the VoiceFlow AI folder**
   - Right-click the folder → **"Open in Terminal"** or **"Open PowerShell window here"**
   - Or manually: `cd C:\path\to\voiceflow-ai`

2. **Run the Setup Script**
   ```powershell
   .\START.ps1
   ```

3. **Follow the Setup Wizard**
   The first-time setup will guide you through:
   - ✅ Microphone testing
   - ✅ Speaker testing  
   - ✅ Voice output preferences
   - ✅ Wake word customization
   - ✅ Optional API key configuration

### **Step 3: Configuration Options**

#### **Basic Configuration (Works Out of the Box)**
- ✅ **Windows Speech Recognition** - Built-in, no setup required
- ✅ **Windows TTS Voice** - Built-in, no setup required
- ✅ **Basic Commands** - Time, calculator, screenshots, browser opening

#### **Enhanced Configuration (Optional)**

##### **🧠 OpenAI Integration (Advanced AI Responses)**
1. **Get an OpenAI API Key**
   - Visit [OpenAI API](https://platform.openai.com/api-keys)
   - Create an account and generate an API key
   - **Cost**: ~$0.01-0.05 per conversation (very affordable)

2. **Add to VoiceFlow AI**
   ```powershell
   # The setup wizard will prompt you, or edit .env manually:
   notepad .env
   # Add: OPENAI_API_KEY=your_key_here
   ```

##### **🎵 ElevenLabs Integration (Premium Voice)**
1. **Get an ElevenLabs API Key**
   - Visit [ElevenLabs](https://elevenlabs.io/)
   - Create account (free tier available)
   - Generate API key from dashboard

2. **Add to VoiceFlow AI**
   ```powershell
   # Add to .env file:
   ELEVENLABS_API_KEY=your_key_here
   ELEVENLABS_VOICE_ID=Rachel  # or your preferred voice
   ```

## 🎤 Testing Your Installation

### **Basic Test**
```powershell
.\START.ps1
# Say: "Ash hello"
# Expected: AI responds with greeting
```

### **Command Test**
```
Say: "Ash what time is it"
Expected: AI tells you the current time

Say: "Open calculator"  
Expected: Windows calculator opens

Say: "Take a screenshot"
Expected: Screenshot saved to desktop
```

### **Conversation Test**
```
Say: "Ash hello"
Wait for response...

Say: "Tell me a joke"
Wait for response...

Say: "What did we just talk about?"
Expected: AI references the previous joke

Say: "Ash stop listening"
Expected: AI says goodbye and stops
```

## 🔧 Troubleshooting

### **🎤 Microphone Issues**

**Problem**: "No speech detected"
```powershell
# Check microphone permissions
1. Windows Settings → Privacy → Microphone
2. Ensure "Allow apps to access microphone" is ON
3. Test with Windows Voice Recorder app
```

**Problem**: "Poor recognition accuracy"
```powershell
# Improve recognition
1. Speak clearly and at normal volume
2. Reduce background noise
3. Position microphone 6-12 inches from mouth
4. Use a quality headset if available
```

### **🔊 Audio Issues**

**Problem**: "No voice output"
```powershell
# Check audio settings
1. Ensure speakers/headphones are connected
2. Check Windows audio output device
3. Test with Windows built-in sounds
```

**Problem**: "ElevenLabs voice not working"
```powershell
# Check API configuration
1. Verify ELEVENLABS_API_KEY in .env file
2. Check internet connection
3. Windows TTS will automatically fallback
```

### **🤖 AI Response Issues**

**Problem**: "Basic responses only, no advanced AI"
```powershell
# This is normal without OpenAI API key
# VoiceFlow AI works great with built-in responses
# Add OpenAI key for advanced conversations
```

**Problem**: "OpenAI API errors"
```powershell
# Check API key and billing
1. Verify OPENAI_API_KEY in .env file
2. Check OpenAI account has available credits
3. Ensure API key has proper permissions
```

### **🚨 Script Execution Issues**

**Problem**: "Execution policy error"
```powershell
# Run once to allow scripts:
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**Problem**: "PowerShell version too old"
```powershell
# Check version:
$PSVersionTable.PSVersion
# Update PowerShell if needed from Microsoft Store
```

## 🎯 Customization

### **Wake Word Customization**
```powershell
# Edit .env file:
WAKE_WORD=YourCustomWord
# Examples: "Computer", "Assistant", "Jarvis", "Friday"
```

### **Voice Customization**
```powershell
# For ElevenLabs users:
ELEVENLABS_VOICE_ID=Rachel     # Female, clear
ELEVENLABS_VOICE_ID=Adam       # Male, deep  
ELEVENLABS_VOICE_ID=Bella      # Female, warm
```

### **Response Style**
```powershell
# Edit the system prompt in the script for personality changes
# Make Ash more formal, casual, funny, professional, etc.
```

## 📁 File Structure

```
voiceflow-ai/
├── 📄 START.ps1                    # Main launcher
├── 📄 easy-setup.ps1               # Setup wizard
├── 📄 .env                         # Configuration file
├── 📂 scripts/
│   ├── voice-assistant-ultimate-fix.ps1  # Main voice assistant
│   ├── say-enhanced.ps1            # Enhanced TTS
│   └── _shared-functions.ps1       # Shared utilities
├── 📂 docs/                        # Documentation
├── 📄 README.md                    # Project overview
└── 📄 INSTALLATION.md              # This file
```

## 🆘 Getting Help

- **📖 Documentation**: Check the `docs/` folder
- **🐛 Issues**: [GitHub Issues](https://github.com/SavageHobbies/VoiceFlow-AI/issues)
- **💬 Community**: [GitHub Discussions](https://github.com/SavageHobbies/VoiceFlow-AI/discussions)
- **📧 Direct Help**: Create an issue with your specific problem

## 🎉 You're All Set!

**Congratulations!** VoiceFlow AI is now ready to use. 

**Start your first conversation:**
```powershell
.\START.ps1
```

**Say:** *"Ash hello"* and enjoy natural voice interaction!

---

**Need help?** Don't hesitate to [create an issue](https://github.com/SavageHobbies/VoiceFlow-AI/issues) - we're here to help! 🤝