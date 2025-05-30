# WinAssistAI Easy Setup
Write-Host "🚀 WinAssistAI Easy Setup" -ForegroundColor Cyan

# Function to get user input
function Get-Input {
    param([string]$Prompt, [string]$Default = "")
    if ($Default) {
        $input = Read-Host "$Prompt (default: $Default)"
        if ($input) {
            return $input
        } else {
            return $Default
        }
    }
    return Read-Host $Prompt
}

Write-Host "`n📋 Let's set up your voice assistant in 3 simple steps:"

# Step 1: ElevenLabs
Write-Host "`n1️⃣ ElevenLabs Voice Setup" -ForegroundColor Green
$useElevenLabs = Get-Input "Use ElevenLabs voice? (y/n)" "y"

if ($useElevenLabs.ToLower() -eq "y") {
    Write-Host "   Get your API key from: https://elevenlabs.io/app/settings/api-keys" -ForegroundColor Yellow
    $elevenLabsKey = Get-Input "   Enter ElevenLabs API key"
    
    # Create .env file
    $envContent = @"
ELEVENLABS_API_KEY=$elevenLabsKey
AI_PROVIDER=OpenAI
OPENAI_API_KEY=YOUR_OPENAI_API_KEY_HERE
WAKE_WORD=Ash
"@
    $envContent | Out-File -FilePath ".env" -Encoding UTF8
    Write-Host "   ✅ ElevenLabs configured!" -ForegroundColor Green
} else {
    Write-Host "   ⏭️ Skipping ElevenLabs (will use Windows voice)" -ForegroundColor Yellow
}

# Step 2: AI Model
Write-Host "`n2️⃣ AI Model Setup" -ForegroundColor Green
Write-Host "   Choose your AI provider:"
Write-Host "   1. OpenAI (GPT-3.5/GPT-4)"
Write-Host "   2. Skip AI (basic responses only)"

$aiChoice = Get-Input "   Enter choice (1-2)" "1"

if ($aiChoice -eq "1") {
    Write-Host "   Get your API key from: https://platform.openai.com/api-keys" -ForegroundColor Yellow
    $openaiKey = Get-Input "   Enter OpenAI API key"
    
    $modelChoice = Get-Input "   Choose model (gpt-3.5-turbo/gpt-4)" "gpt-3.5-turbo"
    
    # Update .env file
    if (Test-Path ".env") {
        $content = Get-Content ".env"
        $content = $content -replace "OPENAI_API_KEY=.*", "OPENAI_API_KEY=$openaiKey"
        $content | Out-File -FilePath ".env" -Encoding UTF8
    }
    
    # Update AI config
    $aiConfig = @{
        default_provider = "OpenAI"
        providers = @{
            OpenAI = @{
                api_key_env = "OPENAI_API_KEY"
                selected_model = $modelChoice
                available_models = @("gpt-4", "gpt-4-turbo", "gpt-3.5-turbo")
            }
        }
    }
    $aiConfig | ConvertTo-Json -Depth 4 | Out-File -FilePath "config/ai_config.json" -Encoding UTF8
    Write-Host "   ✅ AI configured with $modelChoice!" -ForegroundColor Green
} else {
    Write-Host "   ⏭️ Skipping AI setup" -ForegroundColor Yellow
}

# Step 3: Wake Word
Write-Host "`n3️⃣ Wake Word Setup" -ForegroundColor Green
$wakeWord = Get-Input "   Choose wake word" "Ash"

# Update .env file with wake word
if (Test-Path ".env") {
    $content = Get-Content ".env"
    $content = $content -replace "WAKE_WORD=.*", "WAKE_WORD=$wakeWord"
    $content | Out-File -FilePath ".env" -Encoding UTF8
} else {
    "WAKE_WORD=$wakeWord" | Out-File -FilePath ".env" -Encoding UTF8
}

Write-Host "   ✅ Wake word set to '$wakeWord'!" -ForegroundColor Green

# Final setup
Write-Host "`n🎉 Setup Complete!" -ForegroundColor Cyan
Write-Host "=" * 40

Write-Host "`n📊 Your Configuration:" -ForegroundColor White
Write-Host "   🔊 Voice: $(if ($useElevenLabs.ToLower() -eq 'y') { 'ElevenLabs (Rachel)' } else { 'Windows Voice' })"
Write-Host "   🤖 AI: $(if ($aiChoice -eq '1') { "OpenAI ($modelChoice)" } else { 'Basic responses' })"
Write-Host "   💬 Wake Word: '$wakeWord'"

Write-Host "`n🚀 Ready to Start!" -ForegroundColor Green
Write-Host "   Run this command: .\scripts\winassistai-voice.ps1"
Write-Host "   Then say: '$wakeWord hello'"

Write-Host "`n💡 Quick Test:" -ForegroundColor Yellow
Write-Host "   .\scripts\winassistai-voice.ps1 -Test"

Read-Host "`nPress Enter to exit setup"