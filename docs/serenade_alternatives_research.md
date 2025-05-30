# Research: Alternatives to Serenade for WinAssistAI Voice Control

## 1. Introduction

The purpose of this research is to evaluate potential alternatives to Serenade for providing voice control capabilities to the WinAssistAI project. WinAssistAI currently leverages Serenade but is open to exploring other options that might offer enhanced features, easier integration, or better performance for its specific use case on Windows, interacting primarily with PowerShell scripts.

Key desired features for a voice control solution include:
*   **Custom Wake Word:** Ability to activate listening with a specific, preferably customizable, wake word.
*   **Programmatic Control:** APIs or mechanisms to start/stop listening, define command grammars, and receive recognized speech programmatically.
*   **Good Accuracy:** Reliable speech-to-text conversion in typical desktop environments.
*   **Ease of Integration:** Feasibility of integrating with the existing PowerShell-based WinAssistAI architecture.
*   **Windows Compatibility:** Must work reliably on Windows 10/11.

## 2. Evaluation Criteria

The following criteria will be used to evaluate each candidate:

1.  **Ease of Integration:**
    *   Complexity of setting up and integrating with PowerShell.
    *   Availability of SDKs, APIs, or command-line tools suitable for PowerShell.
2.  **Programmatic Control:**
    *   **Wake Word:** Support for custom wake word detection.
    *   **Listening State:** Ability to programmatically start/stop listening.
    *   **Grammar Definition:** Ability to define custom grammars or command sets to improve accuracy for specific tasks.
    *   **Speech Recognition Results:** How results are provided and ease of parsing.
3.  **Accuracy & Performance:**
    *   General speech recognition accuracy.
    *   Performance in terms of speed and resource usage.
    *   Robustness to noise.
4.  **Offline Capabilities:**
    *   Whether the system can operate fully offline or requires an internet connection.
5.  **Licensing:**
    *   Cost, open-source vs. proprietary, any usage limitations.
6.  **Dependencies:**
    *   Software or hardware dependencies required.
    *   Impact on overall project size and complexity.
7.  **Windows Compatibility:**
    *   Official support and performance on Windows 10/11.

## 3. Candidate Evaluation

### Candidate 1: Windows Speech Recognition (WSR) / System.Speech

*   **Overview:**
    Windows Speech Recognition is a built-in feature of the Windows operating system. It can be accessed programmatically through the `System.Speech` namespace in .NET, which is readily available to PowerShell.

*   **Assessment:**
    *   **Ease of Integration:**
        *   High. `System.Speech` is directly accessible from PowerShell. No external SDKs are strictly needed for basic use.
        *   WinAssistAI already uses `System.Speech.Synthesis` for its fallback TTS.
    *   **Programmatic Control:**
        *   **Wake Word:** Not natively supported in a highly customizable way for applications. The Windows global "Hey Cortana" or "Windows Speech Recognition" wake phrases are system-level. Implementing a truly custom, application-specific wake word programmatically is complex and often unreliable with `System.Speech` alone.
        *   **Listening State:** Excellent. PowerShell can easily create `SpeechRecognitionEngine` objects and call `RecognizeAsync()` (and `RecognizeAsyncStop()`/`RecognizeAsyncCancel()`).
        *   **Grammar Definition:** Excellent. `System.Speech.Recognition.GrammarBuilder` and `System.Speech.Recognition.Choices` allow for robust programmatic definition of grammars, which can significantly improve accuracy for command-and-control. SRGS XML grammars are also supported.
        *   **Speech Recognition Results:** Good. Events like `SpeechRecognized` provide detailed results, including confidence scores.
    *   **Accuracy & Performance:**
        *   Accuracy can be decent, especially when constrained by well-defined grammars. For general dictation, it might lag behind cloud-based services.
        *   Performance is generally good as it's a native component. Resource usage is moderate.
    *   **Offline Capabilities:**
        *   Excellent. Fully offline as it's a part of Windows.
    *   **Licensing:**
        *   Free (part of Windows).
    *   **Dependencies:**
        *   Part of Windows. Requires microphone.
    *   **Windows Compatibility:**
        *   Excellent. Native to Windows.

*   **Pros for WinAssistAI:**
    *   No additional software installation required for end-users.
    *   Excellent programmatic control over grammars, listening state (except custom wake word).
    *   Directly usable from PowerShell.
    *   Fully offline.
    *   Free.

*   **Cons for WinAssistAI:**
    *   **Custom Wake Word is a major challenge.** This is a significant drawback if a distinct wake word separate from system features is desired. Workarounds are often clunky.
    *   General dictation accuracy might not be as high as specialized or cloud-based services if not using strict grammars.

### Candidate 2: Vosk API

*   **Overview:**
    Vosk is an offline open-source speech recognition toolkit. It supports multiple languages and platforms, including Windows. It's known for its good offline accuracy with reasonably small models.

*   **Assessment:**
    *   **Ease of Integration:**
        *   Moderate. Vosk provides SDKs for languages like Python, Java, C#, Node.js. For PowerShell, integration would likely involve:
            *   Using a .NET wrapper if a suitable one exists or can be compiled.
            *   Creating a small helper application in a supported language (e.g., Python, C#) that PowerShell calls, which then uses the Vosk SDK.
            *   Direct P/Invoke to its C library is complex from PowerShell.
    *   **Programmatic Control:**
        *   **Wake Word:** Not directly a feature of Vosk's core speech-to-text engine. Wake word detection typically requires a separate, specialized model or library (like Porcupine, see Candidate 3). Vosk itself focuses on continuous speech or short utterance recognition.
        *   **Listening State:** Good, through SDK control (start/stop stream processing).
        *   **Grammar Definition:** Supports dynamic grammars by providing a list of expected phrases, which can significantly improve accuracy for command sets. Not as flexible as SRGS but effective for many cases.
        *   **Speech Recognition Results:** Provides JSON output, which is easy to parse in PowerShell.
    *   **Accuracy & Performance:**
        *   Good offline accuracy, especially with language model customization or speaker adaptation.
        *   Models vary in size and performance; lightweight models are available.
        *   Generally performs well on modern hardware.
    *   **Offline Capabilities:**
        *   Excellent. Fully offline.
    *   **Licensing:**
        *   Apache 2.0 (Open Source). Free for commercial use.
    *   **Dependencies:**
        *   Requires Vosk library/SDK and language models to be distributed or downloaded by the user/application. Models can range from 50MB to a few GB.
    *   **Windows Compatibility:**
        *   Good. Supports Windows via its SDKs.

*   **Pros for WinAssistAI:**
    *   Strong offline capabilities.
    *   Open source and free.
    *   Good accuracy for an offline solution.
    *   Supports dynamic grammars/phrase lists.

*   **Cons for WinAssistAI:**
    *   **No built-in custom wake word detection.**
    *   Integration with PowerShell is not direct; requires a wrapper or inter-process communication with a helper app/script in another language. This adds complexity to the build and deployment.
    *   Requires shipping Vosk model files, increasing application size.

### Candidate 3: Picovoice Platform (Porcupine & Rhino/Leopard)

*   **Overview:**
    Picovoice offers a suite of on-device voice AI products.
    *   **Porcupine:** A highly accurate and efficient wake word engine. Allows custom wake words.
    *   **Rhino:** Speech-to-Intent engine for understanding commands within a specific context (defined grammar).
    *   **Leopard:** Speech-to-Text engine for general dictation.
    All run on-device.

*   **Assessment:**
    *   **Ease of Integration:**
        *   Moderate to High. Picovoice provides SDKs for various languages, including C#, Python, and Node.js. A .NET SDK (for C#) could be used from PowerShell, similar to Vosk, or via a helper app.
        *   They have a direct .NET SDK which might be more PowerShell-friendly than Vosk's.
    *   **Programmatic Control:**
        *   **Wake Word (Porcupine):** Excellent. This is Porcupine's core strength. Allows creating custom wake words using their tools (some free, some paid for custom models). High accuracy and low false alarm rate.
        *   **Listening State:** Excellent, controlled via the SDKs.
        *   **Grammar Definition (Rhino):** Excellent. Rhino is designed for this, using a context file you define (DSL for intents and slots). Very powerful for structured commands.
        *   **Speech Recognition Results (Rhino/Leopard):** Rhino provides structured intent and slot data. Leopard provides transcribed text.
    *   **Accuracy & Performance:**
        *   **Porcupine (Wake Word):** Industry-leading accuracy and very low resource usage.
        *   **Rhino (Intent):** High accuracy when speech matches the defined context grammar.
        *   **Leopard (STT):** Good on-device accuracy.
        *   All components are designed for efficiency on edge devices.
    *   **Offline Capabilities:**
        *   Excellent. All Picovoice components run fully on-device/offline.
    *   **Licensing:**
        *   Free tier available (e.g., Porcupine allows ~3 users/month for custom wake words created with Picovoice Console).
        *   Commercial use generally requires paid licenses, which can vary based on features and scale. Open source projects might have more permissive options (e.g. Porcupine GitHub repo often has a default model with a permissive license).
    *   **Dependencies:**
        *   Requires Picovoice SDK libraries and model files for wake word, and potentially for STT/NLU. These are generally small.
    *   **Windows Compatibility:**
        *   Excellent. Windows is a well-supported platform.

*   **Pros for WinAssistAI:**
    *   **Excellent custom wake word detection (Porcupine).** This is a major advantage.
    *   Strong offline capabilities for all components.
    *   High accuracy and performance, especially for wake word and intent recognition (Rhino).
    *   Good SDKs, with .NET being an option for PowerShell.
    *   Free tier for experimentation and small-scale use.

*   **Cons for WinAssistAI:**
    *   Licensing costs for commercial use or larger-scale custom wake word deployment can be a factor. The free tier for custom wake words is limited.
    *   Integration with PowerShell, while feasible via .NET SDK, still requires managing external libraries and might be more complex than `System.Speech`.

## 4. Comparison Summary

| Feature                 | Windows Speech Recognition (`System.Speech`) | Vosk API                             | Picovoice Platform (Porcupine + Rhino/Leopard) | Serenade (Current)                     |
|-------------------------|----------------------------------------------|--------------------------------------|---------------------------------------------|----------------------------------------|
| **Custom Wake Word**    | Very Difficult / Unreliable                | No (needs separate solution)         | Excellent (Porcupine)                       | Yes (via custom JS, user configured)   |
| **Grammar Control**     | Excellent (SRGS, GrammarBuilder)             | Good (Dynamic phrase lists)          | Excellent (Rhino contexts)                  | Limited (via JS template, predefined commands from JSON) |
| **Offline**             | Yes                                          | Yes                                  | Yes                                         | Yes (core app), custom scripts online? (Unclear for JS environment, but local STT) |
| **PowerShell Integration**| Direct                                       | Moderate (via .NET/helper app)       | Moderate (via .NET SDK/helper app)        | Indirect (via JS bridge to PS)       |
| **Accuracy (General)**  | Fair (better with grammar)                   | Good                                 | Good (Leopard)                              | Good                                   |
| **Licensing**           | Free (Part of Windows)                       | Apache 2.0 (Free)                    | Free Tier / Paid Commercial                 | Free/Paid Tiers                        |
| **Ease of Setup (User)**| None (built-in)                              | Moderate (needs models/libs)         | Moderate (needs models/libs)              | Moderate (app install, script setup)   |
| **Primary Control API** | .NET (`System.Speech`)                       | Python, C#, Java, Node.js SDKs       | Python, C#, .NET, JS, Java SDKs etc.      | Custom JS API, External CLI (PowerShell) |

## 5. Discussion & Recommendation

**Sticking with Serenade:**
*   **Pros:** Already integrated. The new custom script generation (`start-with-serenade.ps1` creating `winassistai-serenade.js`) significantly improves user setup for wake word and path configurations, addressing previous manual setup complexities. The JavaScript API, while a bridge, is functional.
*   **Cons:** The custom JS script's robustness depends on Serenade's API stability and execution environment. Direct `.env` access from JS is not possible, leading to the `WAKE_WORD` synchronization issue (though now partly mitigated by auto-generation if the user only changes `.env` and re-runs `start-with-serenade.ps1`). Deep programmatic control over the voice engine itself (beyond what Serenade's JS API exposes) is limited. If Serenade's STT or wake word performance isn't ideal for some users, there's no alternative within that ecosystem.

**Windows Speech Recognition (`System.Speech`):**
*   **Pros:** Built-in, no extra installs, excellent grammar control for predefined commands, direct PowerShell integration.
*   **Cons:** The lack of a reliable, easy-to-implement custom wake word is a deal-breaker if a distinct wake word is a hard requirement. This was a primary motivator for using Serenade.

**Vosk API:**
*   **Pros:** Good offline STT, open-source, free.
*   **Cons:** No wake word. PowerShell integration is indirect. Still requires users to manage model files.

**Picovoice Platform:**
*   **Pros:** Best-in-class custom wake word (Porcupine). Good offline intent recognition with Rhino (if we define grammars/contexts). Full offline capability. .NET SDK is promising for PowerShell.
*   **Cons:** Licensing for custom wake words beyond the free tier's limits could be an issue for wider distribution if many users want unique wake words. If relying on their generic wake words, this is less of an issue. Integration is more complex than `System.Speech`.

**Discussion based on User Feedback ("We do not need to use Serenade if there is anything better available"):**
This feedback suggests openness to alternatives if they provide tangible benefits. The primary benefits to seek would be:
1.  **More Robust/Easier Custom Wake Word:** Serenade's custom script is a workaround. A native wake word engine is better.
2.  **Simpler Integration Stack:** Reducing JS-to-PowerShell bridging if possible.
3.  **Equivalent or Better Accuracy/Performance.**

**Recommendation:**

1.  **Short-Term - Optimize Serenade:**
    *   The current approach with `start-with-serenade.ps1` automatically generating the `winassistai-serenade.js` (with correct paths and wake word from `.env`) is a significant improvement. This makes Serenade much more viable by simplifying the most complex part of its previous setup.
    *   **Continue with this enhanced Serenade integration for now.** It delivers the core desired features: voice execution of scripts, wake word (albeit with configuration synchronization handled by the startup script), and routing to AI.

2.  **Medium-Term - Prototype with Picovoice (Porcupine):**
    *   **If the Serenade wake word implementation (even with auto-generation) proves problematic (e.g., accuracy issues, Serenade API limitations, user complaints) OR if a more deeply integrated/customizable wake word is desired, Picovoice (Porcupine specifically) is the strongest candidate for a custom wake word.**
    *   A dedicated PowerShell module could be created to wrap the Picovoice .NET SDK. This module would handle:
        *   Loading the Porcupine engine with a wake word model (either a free generic one or one built via Picovoice Console).
        *   Continuously listening for the wake word.
        *   Upon wake word detection, it could then trigger `System.Speech` for command recognition (leveraging its strong grammar capabilities for predefined commands) OR trigger `converse-with-ai.ps1` for free-form input.
    *   This approach combines Porcupine's wake word strength with `System.Speech`'s grammar strength (for predefined commands) and offline capabilities, all controllable from PowerShell.
    *   **Feasibility/Effort:** This would be a new development effort, involving learning the Picovoice SDK and PowerShell module creation.

3.  **Fallback - `System.Speech` without Custom Wake Word:**
    *   If a custom wake word is deemed non-critical, `System.Speech` alone offers the simplest path for voice-enabling predefined commands directly in PowerShell but would lack the "hands-off until called" convenience of a wake word.

**Conclusion on Recommendation:**
For now, **stick with the enhanced Serenade integration** due to the recent improvements in automating its custom script setup. This provides the quickest path to having all desired features (wake word, command execution, AI routing) functional.

However, **initiate a research spike/prototype phase for Picovoice Porcupine + `System.Speech`**. This combination seems to be the most promising long-term solution for robust, offline, custom wake word and command control directly manageable from PowerShell, should Serenade prove unsatisfactory. The licensing for custom Porcupine models needs careful review if many unique wake words are envisioned for end-users; using their generic free models or a limited set of custom ones might be necessary to stay within free/affordable tiers.

Vosk is less attractive due to the lack of a wake word solution and more complex PowerShell integration compared to `System.Speech` or potentially Picovoice via .NET SDK.
