//
//  UI.swift
//  Apple Intelligence Chat
//
//  Created by Mykola Aleshchenko on 31/8/26.
//

import SwiftUI

enum UI {

    // MARK: - Spacing & Padding

    enum Padding {
        /// Standard content padding applied to the scroll view
        static let content: CGFloat = 16
        /// Extra bottom padding so messages aren't hidden behind the input field
        static let scrollBottom: CGFloat = 90
        /// Outer padding around the floating input field
        static let inputField: CGFloat = 20
        /// Inner padding inside the input field bubble
        static let inputFieldInner: CGFloat = 16
        /// Trailing gap between the send button and the input field edge
        static let sendButtonTrailing: CGFloat = 8
        /// Vertical padding on each message row
        static let messageRow: CGFloat = 6
        /// Vertical padding inside the assistant message content
        static let assistantContent: CGFloat = 8
        /// Padding on user bubble
        static let userBubble: CGFloat = 12
        /// Horizontal padding on the web-search badge
        static let badgeHorizontal: CGFloat = 8
        /// Vertical padding on the web-search badge
        static let badgeVertical: CGFloat = 3
        /// Vertical padding on the temperature slider row in Settings
        static let settingsSliderRow: CGFloat = 4
    }

    enum Spacing {
        /// Gap between content items inside an assistant message (text + badge)
        static let assistantStack: CGFloat = 4
        /// Gap between dots in the pulsing loading indicator
        static let pulsingDots: CGFloat = 6
    }

    // MARK: - Sizes

    enum Size {
        /// Minimum height of the text input field
        static let inputFieldMinHeight: CGFloat = 22
        /// Diameter of each dot in the pulsing loading indicator
        static let pulsingDot: CGFloat = 8
        /// Width of the pulsing loading indicator container
        static let pulsingIndicatorWidth: CGFloat = 60
        /// Height of the pulsing loading indicator container
        static let pulsingIndicatorHeight: CGFloat = 25
        /// Font size of the send/stop button icon
        static let sendButtonIcon: CGFloat = 30
        /// Minimum height of the system instructions TextEditor in Settings
        static let settingsInstructionsMinHeight: CGFloat = 100
    }

    // MARK: - Corner Radii

    enum CornerRadius {
        /// Corner radius of the user message bubble
        static let userBubble: CGFloat = 18
    }

    // MARK: - Opacity

    enum Opacity {
        /// Dimmed state of the send button when disabled
        static let sendButtonDisabled: CGFloat = 0.6
        /// Background opacity of the web-search badge
        static let badgeBackground: CGFloat = 0.12
        /// Full opacity for the pulsing dot when animated
        static let pulsingDotActive: CGFloat = 1.0
        /// Reduced opacity for the pulsing dot when idle
        static let pulsingDotIdle: CGFloat = 0.3
        /// Foreground opacity of the pulsing dot
        static let pulsingDotForeground: CGFloat = 0.5
    }

    // MARK: - Animation

    enum Animation {
        /// Duration of the send button icon transition
        static let sendButtonTransition: Double = 0.2
        /// Duration of one pulsing-dot cycle
        static let pulsingDotCycle: Double = 0.6
        /// Delay between consecutive pulsing dots
        static let pulsingDotDelay: Double = 0.2
    }

    // MARK: - Input Field

    enum Input {
        /// Maximum number of lines the input field expands to
        static let lineLimit: Int = 5
    }
}
