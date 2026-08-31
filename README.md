# Apple Intelligence Chat

[![CI](https://github.com/maleshchenko/Apple-Intelligence-Chat/actions/workflows/ci.yml/badge.svg)](https://github.com/maleshchenko/Apple-Intelligence-Chat/actions/workflows/ci.yml)

A native SwiftUI chat app powered by Apple's on-device language model (`FoundationModels`), with optional live web search for current events.

<img width="867" height="914" alt="Screenshot 2026-08-31 at 1 15 29 PM" src="https://github.com/user-attachments/assets/e20ac20c-6b61-4cbf-b3dd-5a1fc15e9515" />


## Limitations

The on-device model has a **4,096 token context window**. Long conversations will hit this limit quickly, the app detects it and recovers by starting a fresh session, but prior conversation history is lost. This is a hard constraint of the current Apple Intelligence model.


## Features

- **On-device inference**: runs entirely on-device via Apple Intelligence, no API keys, no data leaving the device
- **Smart web search**: automatically routes queries about current events, news, sports, and weather through a live Google News search, general knowledge stays on-device
- **Article fetching**: search mode can fetch and summarize full article content from a URL
- **Streaming responses**: token-by-token streaming with haptic feedback
- **Conversation context**: full multi-turn history within a session, with graceful context window recovery
- **Web search badge**: responses sourced from the internet are clearly labelled

## Requirements

| Requirement | Version |
|---|---|
| Xcode | 26.0+ |
| iOS / iPadOS | 26.0+ |
| macOS | 26.0+ |
| Apple Intelligence | Enabled in Settings |

Apple Intelligence must be enabled on the device. The model runs fully on-device, no internet connection is required for general queries (only for web search).

## Getting Started

1. Clone the repo
   ```bash
   git clone https://github.com/maleshchenko/Apple-Intelligence-Chat.git
   ```
2. Open `Apple Intelligence Chat.xcodeproj` in Xcode 26+
3. Select your target device or simulator (iOS 26+)
4. Build and run (`⌘R`)

No dependencies to install — the project uses only system frameworks.

## Architecture

```
ContentView          — pure SwiftUI layout, zero business logic
ChatViewModel        — @Observable class owning all session/message/streaming state
SearchIntentDetector — classifies prompts into onDevice / standard / deepSearch
WebSearchTool        — FoundationModels Tool; searches Google News RSS
ArticleFetchTool     — FoundationModels Tool; fetches and strips article HTML
```

### Session modes

| Mode | Tools | Used when |
|---|---|---|
| `onDevice` | none | General knowledge, code, creative writing |
| `standard` | `WebSearchTool` | News, sports, weather, current events |
| `deepSearch` | `WebSearchTool` + `ArticleFetchTool` | "Read article at…" requests |

Sessions are lazily created and only upgraded (never downgraded) as conversation needs grow.

## Running Tests

```bash
xcodebuild build-for-testing \
  -scheme "Apple Intelligence Chat" \
  -destination "generic/platform=iOS Simulator"

xcodebuild test-without-building \
  -xctestrun "$(find ~/Library/Developer/Xcode/DerivedData -name '*.xctestrun' -path '*Apple_Intelligence*' | head -1)" \
  -destination "platform=iOS Simulator,OS=26.5,name=iPhone 17 Pro"
```

Or press `⌘U` in Xcode. Tests use Swift Testing and cover `SearchIntentDetector`, `SessionMode`, `ChatMessage`, and `SearchUsedFlag`.


## License

MIT — see [LICENSE](LICENSE).
