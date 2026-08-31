//
//  ContentView.swift
//  Apple Intelligence Chat
//
//  Created by Mykola Aleshchenko on 31/8/26.
//

import SwiftUI
import FoundationModels

struct ContentView: View {
    @State private var viewModel = ChatViewModel()
    @State private var inputText = ""
    @State private var showSettings = false

#if os(iOS)
    private let hapticStreamGenerator = UISelectionFeedbackGenerator()
#endif

    var body: some View {
        NavigationStack {
            ZStack {
                messageList
                VStack {
                    Spacer()
                    inputField.padding(UI.Padding.inputField)
                }
            }
            .navigationTitle("Apple Intelligence Chat")
#if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
#endif
            .toolbar { toolbarContent }
            .sheet(isPresented: $showSettings) {
                SettingsView { viewModel.invalidateSession() }
            }
            .alert("Error", isPresented: $viewModel.showErrorAlert) {
                Button("OK") {}
            } message: {
                Text(viewModel.errorMessage)
            }
        }
    }

    // MARK: - Subviews

    private var messageList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack {
                    ForEach(viewModel.messages) { message in
                        MessageView(message: message, isResponding: viewModel.isResponding)
                            .id(message.id)
                    }
                }
                .padding(UI.Padding.content)
                .padding(.bottom, UI.Padding.scrollBottom)
            }
            .accessibilityIdentifier(Accessibility.ID.messageList)
            .onChange(of: viewModel.messages.last?.text) {
                if let last = viewModel.messages.last {
                    withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                }
            }
        }
    }

    private var inputField: some View {
        ZStack {
            TextField("Ask anything", text: $inputText, axis: .vertical)
                .textFieldStyle(.plain)
                .lineLimit(1...UI.Input.lineLimit)
                .frame(minHeight: UI.Size.inputFieldMinHeight)
                .disabled(viewModel.isResponding)
                .onSubmit { submit() }
                .padding(UI.Padding.inputFieldInner)
                .accessibilityIdentifier(Accessibility.ID.inputField)
                .accessibilityHint(Accessibility.Hint.inputField)

            HStack {
                Spacer()
                Button(action: submit) {
                    Image(systemName: viewModel.isResponding ? "stop.circle.fill" : "arrow.up.circle.fill")
                        .font(.system(size: UI.Size.sendButtonIcon, weight: .bold))
                        .foregroundStyle(isSendDisabled ? Color.gray.opacity(UI.Opacity.sendButtonDisabled) : .primary)
                }
                .disabled(isSendDisabled)
                .animation(.easeInOut(duration: UI.Animation.sendButtonTransition), value: viewModel.isResponding)
                .animation(.easeInOut(duration: UI.Animation.sendButtonTransition), value: isSendDisabled)
                .glassEffect(.regular.interactive())
                .padding(.trailing, UI.Padding.sendButtonTrailing)
                .accessibilityIdentifier(Accessibility.ID.sendButton)
                .accessibilityLabel(viewModel.isResponding ? Accessibility.Label.stopGenerating : Accessibility.Label.sendMessage)
                .accessibilityHint(viewModel.isResponding ? Accessibility.Hint.stopButton : Accessibility.Hint.sendButton)
            }
        }
        .glassEffect(.regular.interactive())
    }

    private var isSendDisabled: Bool {
        inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !viewModel.isResponding
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
#if os(iOS)
        ToolbarItem(placement: .navigationBarLeading) {
            Button(action: viewModel.resetConversation) {
                Label("New Chat", systemImage: "square.and.pencil")
            }
            .accessibilityIdentifier(Accessibility.ID.newChatButton)
            .accessibilityHint(Accessibility.Hint.newChatButton)
        }
        ToolbarItem(placement: .navigationBarTrailing) {
            Button { showSettings = true } label: {
                Label("Settings", systemImage: "gearshape")
            }
            .accessibilityIdentifier(Accessibility.ID.settingsButton)
            .accessibilityHint(Accessibility.Hint.settingsButton)
        }
#else
        ToolbarItem {
            Button(action: viewModel.resetConversation) {
                Label("New Chat", systemImage: "square.and.pencil")
            }
            .accessibilityIdentifier(Accessibility.ID.newChatButton)
            .accessibilityHint(Accessibility.Hint.newChatButton)
        }
        ToolbarItem {
            Button { showSettings = true } label: {
                Label("Settings", systemImage: "gearshape")
            }
            .accessibilityIdentifier(Accessibility.ID.settingsButton)
            .accessibilityHint(Accessibility.Hint.settingsButton)
        }
#endif
    }

    // MARK: - Actions

    private func submit() {
        let prompt = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !prompt.isEmpty || viewModel.isResponding else { return }
        inputText = ""
#if os(iOS)
        hapticStreamGenerator.selectionChanged()
#endif
        viewModel.sendOrStop(prompt: prompt)
    }
}

#Preview {
    ContentView()
}
