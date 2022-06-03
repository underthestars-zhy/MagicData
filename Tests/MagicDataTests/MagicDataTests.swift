import XCTest
@testable import MagicData

class TestModel: MagicObject {
    @PrimaryMagicValue var id: String

    @MagicValue var name: String

    @OptionMagicValue var petName: String?

    convenience init(name: String) {
        self.init()
        self.name = name
    }
}

final class MagicDataTests: XCTestCase {
    func testName() async throws {
        let url = URL(fileURLWithPath: "/Users/zhuhaoyu/Downloads")
        print(url)
        let magic = try await MagicData(path: url)
        print(await magic.tableName(of: TestModel(name: "hi")))
    }

    func testAdd() async throws {
        let url = URL(fileURLWithPath: "/Users/zhuhaoyu/Downloads")
        print(url)
        let magic = try await MagicData(path: url)
        let test = TestModel(name: "hi")
        try await magic.update(test)

        test.petName = "az"
        try await magic.update(test)
    }

    func testAsyncAdd() async throws  {
        let url = URL(fileURLWithPath: "/Users/zhuhaoyu/Downloads")

        try await withThrowingTaskGroup(of: Void.self) { group in
            for i in 1...10 {
                let magic = try await MagicData(path: url)
                try await magic.update(TestModel(name: "\(i)"))
            }
        }
    }
}
