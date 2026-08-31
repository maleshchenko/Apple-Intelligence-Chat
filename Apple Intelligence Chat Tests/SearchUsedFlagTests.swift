import Testing
@testable import Apple_Intelligence_Chat

@Suite("SearchUsedFlag")
struct SearchUsedFlagTests {

    @Test("Starts as false")
    func defaultsFalse() async {
        let flag = SearchUsedFlag()
        #expect(await flag.value == false)
    }

    @Test("set() makes value true")
    func canSetTrue() async {
        let flag = SearchUsedFlag()
        await flag.set()
        #expect(await flag.value == true)
    }

    @Test("reset() makes value false after set")
    func canReset() async {
        let flag = SearchUsedFlag()
        await flag.set()
        await flag.reset()
        #expect(await flag.value == false)
    }
}
