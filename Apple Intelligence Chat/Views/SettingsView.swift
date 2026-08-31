//
//  SettingsView.swift
//  Apple Intelligence Chat
//
//  Created by Mykola Aleshchenko on 31/8/26.
//

import SwiftUI

/// App-wide settings stored in UserDefaults
enum AppSettings {
    @AppStorage("useStreaming") static var useStreaming: Bool = true
    @AppStorage("temperature") static var temperature: Double = 0.7
    @AppStorage("systemInstructions") static var systemInstructions: String = "You are an assistant with access to a web search tool. For any question about current events, recent news, sports results, scores, prices, weather, or anything that may have changed after your training data — you MUST call the web search tool before answering. Never guess, invent, or assume the outcome of recent or future events. If a search returns no useful results, say so honestly rather than fabricating an answer."
}

/// Settings screen for configuring AI behavior
struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    var onDismiss: (() -> Void)?
    
    @AppStorage("useStreaming") private var useStreaming = AppSettings.useStreaming
    @AppStorage("temperature") private var temperature = AppSettings.temperature
    @AppStorage("systemInstructions") private var systemInstructions = AppSettings.systemInstructions
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Generation") {
                    Toggle("Stream Responses", isOn: $useStreaming)
                        .accessibilityIdentifier(Accessibility.ID.streamingToggle)
                        .accessibilityHint(Accessibility.Hint.streamingToggle)
                    VStack(alignment: .leading) {
                        Text("Temperature: \(temperature, specifier: "%.2f")")
                        Slider(value: $temperature, in: 0.0...2.0, step: 0.1)
                            .accessibilityIdentifier(Accessibility.ID.temperatureSlider)
                            .accessibilityLabel("Temperature")
                            .accessibilityValue(String(format: "%.2f", temperature))
                            .accessibilityHint(Accessibility.Hint.temperatureSlider)
                    }
                    .padding(.vertical, UI.Padding.settingsSliderRow)
                }

                Section("System Instructions") {
                    TextEditor(text: $systemInstructions)
                        .frame(minHeight: UI.Size.settingsInstructionsMinHeight)
                        .font(.body)
                        .accessibilityIdentifier(Accessibility.ID.instructionsEditor)
                        .accessibilityLabel("System instructions")
                        .accessibilityHint(Accessibility.Hint.instructionsEditor)
                }
            }
            .navigationTitle("Settings")
#if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
#endif
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .accessibilityIdentifier(Accessibility.ID.doneButton)
                        .accessibilityHint(Accessibility.Hint.doneButton)
                }
            }
        }
        .onDisappear { onDismiss?() }
    }
}
