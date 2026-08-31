//
//  SettingsView.swift
//  Apple Intelligence Chat
//
//  Created by Mykola Aleshchenko on 31/8/26.
//

import SwiftUI

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
