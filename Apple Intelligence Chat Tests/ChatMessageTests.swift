import Testing
@testable import Apple_Intelligence_Chat

@Suite("ChatMessage")
struct ChatMessageTests {

    @Test("usedWebSearch defaults to false")
    func webSearchDefaultFalse() {
        let msg = ChatMessage(role: .assistant, text: "Hello")
        #expect(msg.usedWebSearch == false)
    }

    @Test("usedWebSearch can be set to true")
    func webSearchCanBeSet() {
        var msg = ChatMessage(role: .assistant, text: "Hello")
        msg.usedWebSearch = true
        #expect(msg.usedWebSearch == true)
    }

    @Test("Each message gets a unique ID")
    func uniqueIDs() {
        let a = ChatMessage(role: .user, text: "Hi")
        let b = ChatMessage(role: .user, text: "Hi")
        #expect(a.id != b.id)
    }

    @Test("Role is stored correctly")
    func roleStoredCorrectly() {
        #expect(ChatMessage(role: .user, text: "").role == .user)
        #expect(ChatMessage(role: .assistant, text: "").role == .assistant)
        #expect(ChatMessage(role: .system, text: "").role == .system)
    }
}
