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
                    inputField.padding(20)
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
                .padding()
                .padding(.bottom, 90)
            }
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
                .lineLimit(1...5)
                .frame(minHeight: 22)
                .disabled(viewModel.isResponding)
                .onSubmit { submit() }
                .padding(16)

            HStack {
                Spacer()
                Button(action: submit) {
                    Image(systemName: viewModel.isResponding ? "stop.circle.fill" : "arrow.up.circle.fill")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundStyle(isSendDisabled ? Color.gray.opacity(0.6) : .primary)
                }
                .disabled(isSendDisabled)
                .animation(.easeInOut(duration: 0.2), value: viewModel.isResponding)
                .animation(.easeInOut(duration: 0.2), value: isSendDisabled)
                .glassEffect(.regular.interactive())
                .padding(.trailing, 8)
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
        }
        ToolbarItem(placement: .navigationBarTrailing) {
            Button { showSettings = true } label: {
                Label("Settings", systemImage: "gearshape")
            }
        }
#else
        ToolbarItem {
            Button(action: viewModel.resetConversation) {
                Label("New Chat", systemImage: "square.and.pencil")
            }
        }
        ToolbarItem {
            Button { showSettings = true } label: {
                Label("Settings", systemImage: "gearshape")
            }
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
