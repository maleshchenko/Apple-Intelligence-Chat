//
//  AppSettings.swift
//  Apple Intelligence Chat
//
//  Created by Mykola Aleshchenko on 31/8/26.
//

import SwiftUI

/// App-wide settings stored in UserDefaults via @AppStorage.
enum AppSettings {
    @AppStorage("useStreaming") static var useStreaming: Bool = true
    @AppStorage("temperature") static var temperature: Double = 0.7
    @AppStorage("systemInstructions") static var systemInstructions: String = "You are an assistant with access to a web search tool. For any question about current events, recent news, sports results, scores, prices, weather, or anything that may have changed after your training data — you MUST call the web search tool before answering. Never guess, invent, or assume the outcome of recent or future events. If a search returns no useful results, say so honestly rather than fabricating an answer."
}
