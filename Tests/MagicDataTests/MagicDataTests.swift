import XCTest
@testable import MagicData

struct TestModel: MagicObject {
    @PrimaryMagicValue var id: String

    @MagicValue var name: String

    @OptionMagicValue var petName: String?

    init() {

    }

    init(name: String) {
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

        let test1 = test

        test1.petName = "az"
        try await magic.update(test)

        XCTAssertEqual(test.petName, "az")
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

    func testGet() async throws {
        let url = URL(fileURLWithPath: "/Users/zhuhaoyu/Downloads")
        print(url)
        let magic = try await MagicData(path: url)

        let objects = try await magic.object(of: TestModel.self)

        XCTAssertEqual(objects.count, 12)
    }
}
