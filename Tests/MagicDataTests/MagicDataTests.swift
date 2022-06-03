import XCTest
@testable import MagicData

struct TestModel: MagicObject {
    @PrimaryMagicValue var id: String

    @MagicValue var name: String

    @OptionMagicValue var petName: String?
}

final class MagicDataTests: XCTestCase {
    func testAdd() async throws {
        let url = URL(fileURLWithPath: "/Users/zhuhaoyu/Downloads")
        print(url)
        let magic = try await MagicData(path: url)
        let test = TestModel(name: "hi")
        try await magic.update(test)
    }
}
