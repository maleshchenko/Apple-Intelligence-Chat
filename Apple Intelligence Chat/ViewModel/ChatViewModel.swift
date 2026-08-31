//
//  ChatViewModel.swift
//  Apple Intelligence Chat
//
//  Created by Mykola Aleshchenko on 31/8/26.
//

import SwiftUI
import FoundationModels

@MainActor
@Observable
final class ChatViewModel {

    // MARK: - Published State

    var messages: [ChatMessage] = []
    var isResponding = false
    var errorMessage = ""
    var showErrorAlert = false

    // MARK: - Private State

    private var session: LanguageModelSession?
    private var sessionMode: SessionMode = .onDevice
    private var streamingTask: Task<Void, Never>?
    private let model = SystemLanguageModel.default
    private let searchUsedFlag = SearchUsedFlag()

    // MARK: - Settings (read at send time so changes take effect immediately)

    private var useStreaming: Bool {
        get { UserDefaults.standard.object(forKey: "useStreaming") as? Bool ?? AppSettings.useStreaming }
    }
    private var temperature: Double {
        get { UserDefaults.standard.object(forKey: "temperature") as? Double ?? AppSettings.temperature }
    }
    private var systemInstructions: String {
        get { UserDefaults.standard.string(forKey: "systemInstructions") ?? AppSettings.systemInstructions }
    }

    // MARK: - Public Interface

    func sendOrStop(prompt: String) {
        if isResponding {
            stopStreaming()
        } else {
            guard model.isAvailable else {
                let reason = availabilityDescription(for: model.availability)
                showError(String(format: String(localized: "error.session.unavailable"), reason))
                return
            }
            sendMessage(prompt: prompt)
        }
    }

    func resetConversation() {
        stopStreaming()
        messages.removeAll()
        session = nil
        sessionMode = .onDevice
    }

    /// Call after settings change — only resets session, keeps message history.
    func invalidateSession() {
        session = nil
    }

    // MARK: - Private: Sending

    private func sendMessage(prompt: String) {
        isResponding = true
        messages.append(ChatMessage(role: .user, text: prompt))

        let needed = SearchIntentDetector.mode(for: prompt)
        if needed.rank > sessionMode.rank {
            sessionMode = needed
            session = nil
        }

        messages.append(ChatMessage(role: .assistant, text: ""))

        streamingTask = Task {
            do {
                if session == nil { session = makeSession() }
                guard let currentSession = session else {
                    showError(String(localized: "error.session.creation"))
                    isResponding = false
                    return
                }
                try await generate(prompt: prompt, session: currentSession)
            } catch LanguageModelSession.GenerationError.exceededContextWindowSize {
                if messages.last?.role == .assistant { messages.removeLast() }
                messages.append(ChatMessage(role: .system, text: String(localized: "system.context.limit")))
                session = makeSession()
                messages.append(ChatMessage(role: .assistant, text: ""))
                if let freshSession = session {
                    do { try await generate(prompt: prompt, session: freshSession) }
                    catch { showError(String(format: String(localized: "error.generic"), error.localizedDescription)) }
                }
            } catch let e as LanguageModelSession.GenerationError {
                if case .guardrailViolation = e {
                    if messages.last?.role == .assistant { messages.removeLast() }
                    messages.append(ChatMessage(role: .system, text: String(localized: "system.guardrail")))
                } else {
                    showError(String(format: String(localized: "error.generic"), e.localizedDescription))
                }
            } catch is CancellationError {
                // User cancelled — no error shown
            } catch {
                showError(String(format: String(localized: "error.generic"), error.localizedDescription))
            }
            isResponding = false
            streamingTask = nil
        }
    }

    // MARK: - Private: Generation

    private func generate(prompt: String, session: LanguageModelSession) async throws {
        let options = GenerationOptions(temperature: temperature)
        searchUsedFlag.value = false
        for attempt in 1...3 {
            do {
                if attempt > 1 { updateLastMessage("") }
                if useStreaming {
                    let stream = session.streamResponse(to: prompt, options: options)
                    for try await partial in stream {
                        updateLastMessage(partial.content)
                    }
                } else {
                    let response = try await session.respond(to: prompt, options: options)
                    updateLastMessage(response.content)
                }
                if searchUsedFlag.value { messages[messages.count - 1].usedWebSearch = true }
                return
            } catch let e as LanguageModelSession.GenerationError {
                if case .guardrailViolation = e {
                    if attempt == 3 { throw e }
                } else {
                    throw e
                }
            }
        }
    }

    private func updateLastMessage(_ text: String) {
        messages[messages.count - 1].text = text
    }

    private func stopStreaming() {
        streamingTask?.cancel()
    }

    // MARK: - Private: Session Factory

    private func makeSession() -> LanguageModelSession {
        let today = Date.now.formatted(.dateTime.weekday(.wide).month(.wide).day().year())
        let instructions = "Today's date is \(today).\n\n\(systemInstructions)"
        return LanguageModelSession(tools: sessionMode.tools(searchUsedFlag: searchUsedFlag), instructions: instructions)
    }

    // MARK: - Private: Error

    private func showError(_ message: String) {
        errorMessage = message
        showErrorAlert = true
        isResponding = false
    }

    // MARK: - Private: Model Availability

    private func availabilityDescription(for availability: SystemLanguageModel.Availability) -> String {
        switch availability {
        case .available: return "Available"
        case .unavailable(let reason):
            switch reason {
            case .deviceNotEligible: return "Device not eligible"
            case .appleIntelligenceNotEnabled: return "Apple Intelligence not enabled in Settings"
            case .modelNotReady: return "Model assets not downloaded"
            @unknown default: return "Unknown reason"
            }
        @unknown default: return "Unknown availability"
        }
    }
}

// MARK: - Session Mode

enum SessionMode: Equatable {
    case onDevice, standard, deepSearch

    var rank: Int {
        switch self { case .onDevice: return 0; case .standard: return 1; case .deepSearch: return 2 }
    }

    func tools(searchUsedFlag: SearchUsedFlag) -> [any Tool] {
        switch self {
        case .onDevice:   return []
        case .standard:   return [WebSearchTool(searchUsedFlag: searchUsedFlag)]
        case .deepSearch: return [WebSearchTool(searchUsedFlag: searchUsedFlag), ArticleFetchTool()]
        }
    }
}

// MARK: - Search Intent Detection

enum SearchIntentDetector {
    private static let deepTerms = ["read article", "open article", "fetch article", "full article", "read the article"]
    private static let searchTerms = [
        "search for", "look up", "lookup", "find online", "google",
        "latest", "recent", "current news", "right now",
        "today's", "this week", "this month",
        "news about", "what happened", "who won", "what's the score",
        "weather", "price of", "stock price"
    ]

    static func mode(for prompt: String) -> SessionMode {
        let lower = prompt.lowercased()
        if deepTerms.contains(where: lower.contains) { return .deepSearch }
        if searchTerms.contains(where: lower.contains) { return .standard }
        return .onDevice
    }
}
