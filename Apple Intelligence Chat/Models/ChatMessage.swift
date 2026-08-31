//
//  ChatMessage.swift
//  Apple Intelligence Chat
//
//  Created by Mykola Aleshchenko on 31/8/26.
//

import Foundation

enum ChatRole {
    case user
    case assistant
    case system
}

struct ChatMessage: Identifiable, Equatable {
    let id = UUID()
    var role: ChatRole
    var text: String
    var usedWebSearch: Bool = false
}
