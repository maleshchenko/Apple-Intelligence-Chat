//
//  Accessibility.swift
//  Apple Intelligence Chat
//
//  Created by Mykola Aleshchenko on 31/8/26.
//

enum Accessibility {

    // MARK: - Identifiers (strings for UI automation)

    enum ID {
        static let messageList         = "messageList"
        static let messageRow          = "messageRow"
        static let inputField          = "inputField"
        static let sendButton          = "sendButton"
        static let newChatButton       = "newChatButton"
        static let settingsButton      = "settingsButton"
        static let webSearchBadge      = "webSearchBadge"
        static let generatingIndicator = "generatingIndicator"
        static let streamingToggle     = "streamingToggle"
        static let temperatureSlider   = "temperatureSlider"
        static let instructionsEditor  = "instructionsEditor"
        static let doneButton          = "doneButton"
    }

    // MARK: - Labels (VoiceOver reads these instead of the raw view content)

    enum Label {
        static let sendMessage        = "Send message"
        static let stopGenerating     = "Stop generating"
        static let generatingResponse = "Generating response"
        static let webSearchBadge     = "Response sourced from web search"
        static let userMessage        = "You"
        static let assistantMessage   = "Assistant"
        static let systemMessage      = "System notice"
    }

    // MARK: - Hints (read after the label, describes the action)

    enum Hint {
        static let inputField         = "Type your message here"
        static let sendButton         = "Sends your message to the assistant"
        static let stopButton         = "Stops the current response"
        static let newChatButton      = "Clears the conversation and starts fresh"
        static let settingsButton     = "Opens model and behaviour settings"
        static let streamingToggle    = "When on, the response appears word by word as it is generated"
        static let temperatureSlider  = "Higher values make responses more creative; lower values make them more focused"
        static let instructionsEditor = "These instructions are sent to the model before every conversation"
        static let doneButton         = "Saves settings and returns to the chat"
    }
}
