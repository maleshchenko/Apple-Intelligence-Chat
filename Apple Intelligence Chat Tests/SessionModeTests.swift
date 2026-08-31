import Testing
@testable import Apple_Intelligence_Chat

@Suite("SessionMode")
struct SessionModeTests {

    // MARK: - Rank ordering

    @Test("onDevice has the lowest rank")
    func rankOrdering() {
        #expect(SessionMode.onDevice.rank < SessionMode.standard.rank)
        #expect(SessionMode.standard.rank < SessionMode.deepSearch.rank)
    }

    @Test("Rank values are unique")
    func rankUniqueness() {
        let ranks = [SessionMode.onDevice.rank, SessionMode.standard.rank, SessionMode.deepSearch.rank]
        #expect(Set(ranks).count == ranks.count)
    }

    // MARK: - Tool counts

    @Test("onDevice provides no tools")
    func onDeviceHasNoTools() {
        let flag = SearchUsedFlag()
        #expect(SessionMode.onDevice.tools(searchUsedFlag: flag).isEmpty)
    }

    @Test("standard provides exactly one tool")
    func standardHasOneSearchTool() {
        let flag = SearchUsedFlag()
        #expect(SessionMode.standard.tools(searchUsedFlag: flag).count == 1)
    }

    @Test("deepSearch provides exactly two tools")
    func deepSearchHasTwoTools() {
        let flag = SearchUsedFlag()
        #expect(SessionMode.deepSearch.tools(searchUsedFlag: flag).count == 2)
    }
}
