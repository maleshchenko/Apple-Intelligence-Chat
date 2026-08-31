//
//  SearchUsedFlag.swift
//  Apple Intelligence Chat
//
//  Created by Mykola Aleshchenko on 31/8/26.
//

/// Thread-safe flag written by WebSearchTool, read by ChatViewModel after generation.
actor SearchUsedFlag {
    var value = false

    func set() { value = true }
    func reset() { value = false }
}
