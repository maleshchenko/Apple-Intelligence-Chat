//
//  MessageView.swift
//  Apple Intelligence Chat
//
//  Created by Mykola Aleshchenko on 31/8/26.
//

import SwiftUI

/// View for displaying a single chat message
struct MessageView: View {
    let message: ChatMessage
    let isResponding: Bool
    
    var body: some View {
        HStack {
            if message.role == .system {
                Spacer()
                Text(message.text)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                Spacer()
            } else if message.role == .user {
                Spacer()
                Text(message.text)
                    .padding(UI.Padding.userBubble)
                    .foregroundColor(.white)
                    .background(.blue)
                    .clipShape(.rect(cornerRadius: UI.CornerRadius.userBubble))
                    .glassEffect(in: .rect(cornerRadius: UI.CornerRadius.userBubble))
                    .accessibilityLabel("\(Accessibility.Label.userMessage): \(message.text)")
            } else {
                VStack(alignment: .leading, spacing: UI.Spacing.assistantStack) {
                    if message.text.isEmpty && isResponding {
                        PulsingDotView()
                            .frame(width: UI.Size.pulsingIndicatorWidth, height: UI.Size.pulsingIndicatorHeight)
                            .accessibilityIdentifier(Accessibility.ID.generatingIndicator)
                            .accessibilityLabel(Accessibility.Label.generatingResponse)
                    } else {
                        Text(message.text)
                            .textSelection(.enabled)
                            .accessibilityLabel("\(Accessibility.Label.assistantMessage): \(message.text)")
                    }
                    if message.usedWebSearch {
                        Label("Web search", systemImage: "globe")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, UI.Padding.badgeHorizontal)
                            .padding(.vertical, UI.Padding.badgeVertical)
                            .background(.secondary.opacity(UI.Opacity.badgeBackground), in: Capsule())
                            .accessibilityIdentifier(Accessibility.ID.webSearchBadge)
                            .accessibilityLabel(Accessibility.Label.webSearchBadge)
                            .accessibilityAddTraits(.isStaticText)
                    }
                }
                .padding(.vertical, UI.Padding.assistantContent)
                Spacer()
            }
        }
        .padding(.vertical, UI.Padding.messageRow)
        .accessibilityIdentifier(Accessibility.ID.messageRow)
    }
}

/// Animated loading indicator shown while AI is generating a response
private struct PulsingDotView: View {
    @State private var isAnimating = false
    
    var body: some View {
        HStack(spacing: UI.Spacing.pulsingDots) {
            ForEach(0..<3) { index in
                Circle()
                    .frame(width: UI.Size.pulsingDot, height: UI.Size.pulsingDot)
                    .foregroundStyle(.primary.opacity(UI.Opacity.pulsingDotForeground))
                    .scaleEffect(isAnimating ? 1.0 : 0.5)
                    .opacity(isAnimating ? UI.Opacity.pulsingDotActive : UI.Opacity.pulsingDotIdle)
                    .animation(
                        .easeInOut(duration: UI.Animation.pulsingDotCycle)
                            .repeatForever()
                            .delay(Double(index) * UI.Animation.pulsingDotDelay),
                        value: isAnimating
                    )
                    .accessibilityHidden(true)
            }
        }
        .onAppear { isAnimating = true }
    }
}
