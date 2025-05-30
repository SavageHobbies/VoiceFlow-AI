# 🎤 VoiceFlow AI - The Natural Conversational Voice Assistant

[![PowerShell](https://img.shields.io/badge/PowerShell-5391FE?style=for-the-badge&logo=powershell&logoColor=white)](https://docs.microsoft.com/en-us/powershell/)
[![Windows](https://img.shields.io/badge/Windows-0078D6?style=for-the-badge&logo=windows&logoColor=white)](https://www.microsoft.com/)
[![OpenAI](https://img.shields.io/badge/OpenAI-412991?style=for-the-badge&logo=openai&logoColor=white)](https://openai.com/)
[![ElevenLabs](https://img.shields.io/badge/ElevenLabs-000000?style=for-the-badge&logo=&logoColor=white)](https://elevenlabs.io/)

> **The most natural voice assistant for Windows** - Say the wake word once, then chat like you're talking to a friend.

## 🌟 What Makes VoiceFlow AI Special?

**No more repetitive wake words!** Traditional voice assistants make you say "Hey Assistant" before every single command. VoiceFlow AI revolutionizes this:

### Traditional Voice Assistants:
```
❌ "Hey Assistant, what time is it?"
❌ "Hey Assistant, open Chrome"  
❌ "Hey Assistant, tell me a joke"
❌ "Hey Assistant, take a screenshot"
```

### VoiceFlow AI:
```
✅ "Ash hello"
   → "Hi! What can I help you with?"
✅ "What time is it?"
   → "It's 3:45 PM on Tuesday, January 30th"
✅ "Open Chrome"  
   → "Opening Google Chrome for you!"
✅ "Tell me a joke"
   → "Why don't scientists trust atoms? Because they make up everything!"
✅ "Ash stop listening"
   → "Goodbye! Have a great day!"
```

## 🚀 Key Features

- **🗣️ Truly Conversational** - Say wake word once, then chat naturally
- **🧠 Conversation Memory** - Remembers your chat history and context
- **🎤 Premium Voice Quality** - ElevenLabs integration with Windows TTS fallback
- **🔧 Task Automation** - Opens apps, takes screenshots, tells time, and more
- **🎯 Smart Recognition** - Optimized for clear English speakers
- **🔇 Self-Hearing Prevention** - Advanced audio control prevents feedback loops
- **⚡ Quick Setup** - Automated configuration in under 5 minutes
- **🎨 Extensible** - Easy to add new commands and integrations

## 🎬 Demo

**Watch VoiceFlow AI in action:**

```
🎤 You: "Ash hello"
🤖 Ash: "Hi! I'm listening. What would you like to talk about?"

🎤 You: "Open Google Chrome and tell me the time"
🤖 Ash: "Opening Google Chrome for you! The current time is 3:45 PM."

🎤 You: "Take a screenshot and tell me a joke"
🤖 Ash: "Screenshot captured! Here's a joke: Why did the programmer quit? Because they didn't get arrays!"

🎤 You: "Remember what we talked about Chrome earlier?"
🤖 Ash: "Yes! I opened Chrome for you. Are you looking for help with anything else?"

🎤 You: "Ash stop listening"  
🤖 Ash: "Goodbye! It was wonderful chatting with you!"
```

## ⚡ Quick Start

### 1. **Clone & Run**
```powershell
git clone https://github.com/SavageHobbies/VoiceFlow-AI.git
cd voiceflow-ai
.\START.ps1
```

### 2. **First-Time Setup** (2 minutes)
- The setup wizard will guide you through configuration
- Optional: Add your OpenAI API key for advanced AI responses
- Optional: Add your ElevenLabs API key for premium voice

### 3. **Start Chatting**
```powershell
.\START.ps1
# Say: "Ash hello" and start your conversation!
```

## 🛠️ What Can VoiceFlow AI Do?

### **Built-in Commands**
- 🕒 **Time**: "What time is it?"
- 🧮 **Calculator**: "Open calculator"
- 📸 **Screenshots**: "Take a screenshot"
- 🌐 **Browsers**: "Open Chrome/Firefox/Edge"
- 👋 **Greetings**: "Hello", "How are you?"

### **AI-Powered Conversations**
- 💬 **Natural chat**: "Tell me about quantum physics"
- 🤣 **Jokes**: "Tell me a funny joke"
- 📖 **Stories**: "Tell me a story"
- 🤔 **Questions**: "What's the meaning of life?"
- 🧠 **Context awareness**: "What did we talk about earlier?"

### **Task Automation**
- 📁 **File operations**: "Create a file on desktop"
- 🔍 **Web searches**: "Search for Python tutorials"
- 📧 **Email drafting**: "Help me write an email"
- 🎵 **Media control**: "Play music"

## 🔧 Technical Architecture

**VoiceFlow AI** is built with modern Windows speech recognition and AI integration:

- **Speech Recognition**: Windows Speech Platform with custom optimizations
- **AI Brain**: OpenAI GPT integration with conversation memory
- **Voice Output**: ElevenLabs premium voices with Windows TTS fallback
- **Task Execution**: PowerShell automation for Windows integration
- **Memory System**: Conversation context and history tracking

## 🎯 Why Contribute to VoiceFlow AI?

### **For Developers**
- 🧪 **Cutting-edge AI**: Work with latest OpenAI and speech tech
- 🎨 **Creative Freedom**: Add new commands, voices, and features
- 🌍 **Real Impact**: Help people interact with computers naturally
- 📚 **Learn**: Speech recognition, AI integration, Windows automation

### **For Users**
- 🗣️ **Shape the future** of voice interaction
- 🐛 **Report bugs** and suggest features
- 📖 **Documentation**: Help others get started
- 🎤 **Testing**: Try new features and provide feedback

## 🤝 Contributing

We're looking for passionate contributors! Here's how to get involved:

### **🔥 High-Priority Areas**
- **🎤 Voice Recognition Improvements** - Better accuracy and language support
- **🧠 AI Integration** - New AI providers and response types  
- **🎨 UI/UX** - Desktop GUI, system tray integration
- **🌐 Web Integration** - Browser automation, API integrations
- **📱 Mobile** - Cross-platform support
- **🔌 Plugin System** - Extensible architecture for custom commands

### **💡 Feature Ideas**
- **Smart Home Integration** (Philips Hue, smart switches)
- **Calendar & Email Integration** (Outlook, Google)
- **Media Control** (Spotify, YouTube, VLC)
- **Code Assistant** (GitHub integration, code generation)
- **Language Support** (Spanish, French, German, etc.)
- **Voice Cloning** (Train custom voices)

### **🚀 Getting Started Contributing**
1. **Fork** the repository
2. **Clone** your fork: `git clone https://github.com/yourusername/VoiceFlow-AI.git`
3. **Create feature branch**: `git checkout -b feature/amazing-new-feature`
4. **Code your feature** and test thoroughly
5. **Submit a Pull Request** with detailed description

## 📚 Documentation

- **[Installation Guide](INSTALLATION.md)** - Detailed setup instructions
- **[API Documentation](docs/API.md)** - Extending VoiceFlow AI
- **[Contributing Guide](CONTRIBUTING.md)** - How to contribute code
- **[Troubleshooting](docs/TROUBLESHOOTING.md)** - Common issues and fixes

## 🎖️ Contributors

Thanks to these amazing people who've helped make VoiceFlow AI better:

<!-- Contributors will be added here -->

## 📄 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

## 🌟 Star History

[![Star History Chart](https://api.star-history.com/svg?repos=SavageHobbies/VoiceFlow-AI&type=Date)](https://star-history.com/#SavageHobbies/VoiceFlow-AI&Date)

## 💬 Community

- **💬 Discord**: [Join our community](https://discord.gg/voiceflow-ai)
- **🐛 Issues**: [Report bugs or request features](https://github.com/SavageHobbies/VoiceFlow-AI/issues)
- **💡 Discussions**: [Share ideas and get help](https://github.com/SavageHobbies/VoiceFlow-AI/discussions)

---

**Made with ❤️ for the Windows community**

*VoiceFlow AI - Where conversation meets automation*
