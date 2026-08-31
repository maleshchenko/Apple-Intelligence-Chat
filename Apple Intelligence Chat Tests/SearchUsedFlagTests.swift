import Testing
@testable import Apple_Intelligence_Chat

@Suite("SearchUsedFlag")
struct SearchUsedFlagTests {

    @Test("Starts as false")
    func defaultsFalse() {
        #expect(SearchUsedFlag().value == false)
    }

    @Test("Can be set to true")
    func canSetTrue() {
        let flag = SearchUsedFlag()
        flag.value = true
        #expect(flag.value == true)
    }

    @Test("Can be reset to false")
    func canReset() {
        let flag = SearchUsedFlag()
        flag.value = true
        flag.value = false
        #expect(flag.value == false)
    }
}
