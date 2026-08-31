import Testing
@testable import Apple_Intelligence_Chat

@Suite("SearchIntentDetector")
struct SearchIntentDetectorTests {

    // MARK: - On-device (no tools)

    @Test("General knowledge stays on-device")
    func generalKnowledge() {
        #expect(SearchIntentDetector.mode(for: "Explain quantum entanglement") == .onDevice)
        #expect(SearchIntentDetector.mode(for: "Write a haiku about the ocean") == .onDevice)
        #expect(SearchIntentDetector.mode(for: "What is the capital of France?") == .onDevice)
        #expect(SearchIntentDetector.mode(for: "How do I reverse a string in Swift?") == .onDevice)
    }

    @Test("Empty prompt stays on-device")
    func emptyPrompt() {
        #expect(SearchIntentDetector.mode(for: "") == .onDevice)
    }

    // MARK: - Standard (web search)

    @Test("Explicit search intent triggers standard mode")
    func explicitSearchIntent() {
        #expect(SearchIntentDetector.mode(for: "Search for the best coffee shops in Kyiv") == .standard)
        #expect(SearchIntentDetector.mode(for: "Look up the iPhone 17 price") == .standard)
        #expect(SearchIntentDetector.mode(for: "Find online reviews for the new MacBook") == .standard)
    }

    @Test("Current-events keywords trigger standard mode")
    func currentEventsKeywords() {
        #expect(SearchIntentDetector.mode(for: "What's the latest news about AI?") == .standard)
        #expect(SearchIntentDetector.mode(for: "Who won the latest Formula 1 Grand Prix?") == .standard)
        #expect(SearchIntentDetector.mode(for: "What happened in tech this week?") == .standard)
        #expect(SearchIntentDetector.mode(for: "Today's weather in Kyiv") == .standard)
        #expect(SearchIntentDetector.mode(for: "Current news about the economy") == .standard)
    }

    @Test("Sports result keywords trigger standard mode")
    func sportsKeywords() {
        #expect(SearchIntentDetector.mode(for: "What's the score of the Champions League final?") == .standard)
        #expect(SearchIntentDetector.mode(for: "Who won the match last night?") == .standard)
    }

    @Test("Financial keywords trigger standard mode")
    func financialKeywords() {
        #expect(SearchIntentDetector.mode(for: "What is the stock price of Apple?") == .standard)
        #expect(SearchIntentDetector.mode(for: "Price of Bitcoin right now") == .standard)
    }

    // MARK: - Deep search (web search + article fetch)

    @Test("Article-fetch phrases trigger deep-search mode")
    func articleFetchPhrases() {
        #expect(SearchIntentDetector.mode(for: "Read article about the new iPhone") == .deepSearch)
        #expect(SearchIntentDetector.mode(for: "Open article from that link") == .deepSearch)
        #expect(SearchIntentDetector.mode(for: "Fetch article at this URL") == .deepSearch)
        #expect(SearchIntentDetector.mode(for: "Show me the full article") == .deepSearch)
        #expect(SearchIntentDetector.mode(for: "Read the article for me") == .deepSearch)
    }

    @Test("Deep search takes priority over standard search terms")
    func deepSearchPriority() {
        // A prompt that mentions both article-fetch and search keywords → deepSearch wins
        #expect(SearchIntentDetector.mode(for: "Search and read article about F1") == .deepSearch)
    }

    // MARK: - Case insensitivity

    @Test("Detection is case-insensitive")
    func caseInsensitive() {
        #expect(SearchIntentDetector.mode(for: "LATEST news about AI") == .standard)
        #expect(SearchIntentDetector.mode(for: "READ ARTICLE about climate") == .deepSearch)
    }
}
