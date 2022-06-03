import XCTest
@testable import MagicData

struct TestModel: MagicObject {
    @PrimaryMagicValue var id: String
    @MagicValue var name: String
    @OptionMagicValue var petName: String?

    init() {
        self.id = ""
        self.name = ""
    }
}

final class MagicDataTests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        
    }
}
