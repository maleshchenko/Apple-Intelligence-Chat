//
//  ContentView.swift
//  Apple Intelligence Chat
//
//  Created by Mykola Aleshchenko on 31/8/26.
//

import SwiftUI
import FoundationModels

/// Main chat interface view
struct ContentView: View {
    // MARK: - State Properties
    
    // UI State
    @State private var messages: [ChatMessage] = []
    @State private var inputText: String = ""
    @State private var isResponding = false
    @State private var showSettings = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    
    // Model State
    @State private var session: LanguageModelSession?
    @State private var sessionMode: SessionMode = .onDevice
    @State private var streamingTask: Task<Void, Never>?
    @State private var model = SystemLanguageModel.default
    private let searchUsedFlag = SearchUsedFlag()
    
    // Settings
    @AppStorage("useStreaming") private var useStreaming = AppSettings.useStreaming
    @AppStorage("temperature") private var temperature = AppSettings.temperature
    @AppStorage("systemInstructions") private var systemInstructions = AppSettings.systemInstructions
    
    // Haptics
#if os(iOS)
    private let hapticStreamGenerator = UISelectionFeedbackGenerator()
#endif
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Chat Messages ScrollView
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack {
                            ForEach(messages) { message in
                                MessageView(message: message, isResponding: isResponding)
                                    .id(message.id)
                            }
                        }
                        .padding()
                        .padding(.bottom, 90) // Space for floating input field
                    }
                    .onChange(of: messages.last?.text) {
                        if let lastMessage = messages.last {
                            withAnimation {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }
                
                // Floating Input Field
                VStack {
                    Spacer()
                    inputField
                        .padding(20)
                }
            }
            .navigationTitle("Apple Intelligence Chat")
#if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
#endif
            .toolbar { toolbarContent }
            .sheet(isPresented: $showSettings) {
                SettingsView {
                    session = nil // Reset session on settings change
                }
            }
            .alert("Error", isPresented: $showErrorAlert) {
                Button("OK") {}
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    // MARK: - Subviews
    
    /// Floating input field with send/stop button
    private var inputField: some View {
        ZStack {
            TextField("Ask anything", text: $inputText, axis: .vertical)
                .textFieldStyle(.plain)
                .lineLimit(1...5)
                .frame(minHeight: 22)
                .disabled(isResponding)
                .onSubmit {
                    if !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        handleSendOrStop()
                    }
                }
                .padding(16)
            
            HStack {
                Spacer()
                Button(action: handleSendOrStop) {
                    Image(systemName: isResponding ? "stop.circle.fill" : "arrow.up.circle.fill")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundStyle(isSendButtonDisabled ? Color.gray.opacity(0.6) : .primary)
                }
                .disabled(isSendButtonDisabled)
                .animation(.easeInOut(duration: 0.2), value: isResponding)
                .animation(.easeInOut(duration: 0.2), value: isSendButtonDisabled)
                .glassEffect(.regular.interactive())
                .padding(.trailing, 8)
            }
        }
        .glassEffect(.regular.interactive())
    }
    
    private var isSendButtonDisabled: Bool {
        return inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isResponding
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
#if os(iOS)
        ToolbarItem(placement: .navigationBarLeading) {
            Button(action: resetConversation) {
                Label("New Chat", systemImage: "square.and.pencil")
            }
        }
        ToolbarItem(placement: .navigationBarTrailing) {
            Button(action: { showSettings = true }) {
                Label("Settings", systemImage: "gearshape")
            }
        }
#else
        ToolbarItem {
            Button(action: resetConversation) {
                Label("New Chat", systemImage: "square.and.pencil")
            }
        }
        ToolbarItem {
            Button(action: { showSettings = true }) {
                Label("Settings", systemImage: "gearshape")
            }
        }
#endif
    }
    
    // MARK: - Model Interaction
    
    private func handleSendOrStop() {
        if isResponding {
            stopStreaming()
        } else {
            guard model.isAvailable else {
                showError(message: "The language model is not available. Reason: \(availabilityDescription(for: model.availability))")
                return
            }
            sendMessage()
        }
    }
    
    private func sendMessage() {
        isResponding = true
        let userMessage = ChatMessage(role: .user, text: inputText)
        messages.append(userMessage)
        let prompt = inputText
        inputText = ""
        
        // Upgrade session tools if this message needs more capability (never downgrade)
        let needed = modeForPrompt(prompt)
        if needed.rank > sessionMode.rank {
            sessionMode = needed
            session = nil
        }
        
        messages.append(ChatMessage(role: .assistant, text: ""))
        
        streamingTask = Task {
            do {
                if session == nil { session = createSession() }
                guard let currentSession = session else {
                    showError(message: "Session could not be created.")
                    isResponding = false
                    return
                }
                try await generate(prompt: prompt, session: currentSession)
            } catch LanguageModelSession.GenerationError.exceededContextWindowSize(_) {
                // Drop the partial response and notify the user inline
                if messages.last?.role == .assistant { messages.removeLast() }
                messages.append(ChatMessage(role: .system, text: "Context limit reached — conversation history was cleared."))
                // Retry in a fresh session
                session = createSession()
                messages.append(ChatMessage(role: .assistant, text: ""))
                if let freshSession = session {
                    do {
                        try await generate(prompt: prompt, session: freshSession)
                    } catch {
                        showError(message: "An error occurred: \(error.localizedDescription)")
                    }
                }
            } catch let e as LanguageModelSession.GenerationError {
                if case .guardrailViolation = e {
                    if messages.last?.role == .assistant { messages.removeLast() }
                    messages.append(ChatMessage(role: .system, text: "The model declined to respond after 3 attempts. Try rephrasing your question."))
                } else {
                    showError(message: "An error occurred: \(e.localizedDescription)")
                }
            } catch is CancellationError {
                // User cancelled generation
            } catch {
                showError(message: "An error occurred: \(error.localizedDescription)")
            }
            
            isResponding = false
            streamingTask = nil
        }
    }
    
    private func generate(prompt: String, session: LanguageModelSession) async throws {
        let options = GenerationOptions(temperature: temperature)
        searchUsedFlag.value = false
        for attempt in 1...3 {
            do {
                if attempt > 1 { updateLastMessage(with: "") }
                if useStreaming {
                    let stream = session.streamResponse(to: prompt, options: options)
                    for try await partialResponse in stream {
#if os(iOS)
                        hapticStreamGenerator.selectionChanged()
#endif
                        updateLastMessage(with: partialResponse.content)
                    }
                } else {
                    let response = try await session.respond(to: prompt, options: options)
                    updateLastMessage(with: response.content)
                }
                if searchUsedFlag.value { markLastMessageWebSearch() }
                return
            } catch let e as LanguageModelSession.GenerationError {
                if case .guardrailViolation = e {
                    if attempt == 3 { throw e }
                    // else retry silently
                } else {
                    throw e
                }
            }
        }
    }

    @MainActor
    private func markLastMessageWebSearch() {
        messages[messages.count - 1].usedWebSearch = true
    }
    
    private func stopStreaming() {
        streamingTask?.cancel()
    }
    
    @MainActor
    private func updateLastMessage(with text: String) {
        messages[messages.count - 1].text = text
    }
    
    // MARK: - Session & Helpers
    
    private func createSession() -> LanguageModelSession {
        let today = Date.now.formatted(.dateTime.weekday(.wide).month(.wide).day().year())
        let instructions = "Today's date is \(today).\n\n\(systemInstructions)"
        return LanguageModelSession(tools: tools(for: sessionMode), instructions: instructions)
    }
    
    private func resetConversation() {
        stopStreaming()
        messages.removeAll()
        session = nil
        sessionMode = .onDevice
    }
    
    private func modeForPrompt(_ prompt: String) -> SessionMode {
        let lower = prompt.lowercased()
        let deepTerms = ["read article", "open article", "fetch article", "full article", "read the article"]
        if deepTerms.contains(where: lower.contains) { return .deepSearch }
        let searchTerms = [
            "search", "look up", "lookup", "find online", "google",
            "latest", "recent", "current", "today", "news", "right now",
            "what is the", "who is", "what are", "when did", "where is",
            "weather", "price of", "stock", "score"
        ]
        if searchTerms.contains(where: lower.contains) { return .standard }
        return .onDevice
    }

    private enum SessionMode: Equatable {
        case onDevice, standard, deepSearch

        var rank: Int {
            switch self { case .onDevice: return 0; case .standard: return 1; case .deepSearch: return 2 }
        }
    }

    private func tools(for mode: SessionMode) -> [any Tool] {
        switch mode {
        case .onDevice: return []
        case .standard: return [WebSearchTool(searchUsedFlag: searchUsedFlag)]
        case .deepSearch: return [WebSearchTool(searchUsedFlag: searchUsedFlag), ArticleFetchTool()]
        }
    }
    
    private func availabilityDescription(for availability: SystemLanguageModel.Availability) -> String {
        switch availability {
            case .available:
                return "Available"
            case .unavailable(let reason):
                switch reason {
                    case .deviceNotEligible:
                        return "Device not eligible"
                    case .appleIntelligenceNotEnabled:
                        return "Apple Intelligence not enabled in Settings"
                    case .modelNotReady:
                        return "Model assets not downloaded"
                    @unknown default:
                        return "Unknown reason"
                }
            @unknown default:
                return "Unknown availability"
        }
    }
    
    @MainActor
    private func showError(message: String) {
        self.errorMessage = message
        self.showErrorAlert = true
        self.isResponding = false
    }
}

#Preview {
    ContentView()
}
