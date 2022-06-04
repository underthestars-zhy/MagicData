import XCTest
@testable import MagicData

struct TestModel: MagicObject {
    @PrimaryMagicValue var id: String

    @MagicValue var name: String
    @MagicValue var age: Int

    @OptionMagicValue var petName: String?
    @OptionMagicValue var hight: Double?

    init() {}

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
        test.age = 1
        try await magic.update(test)

        let test1 = test

        test1.petName = "az"
        test1.name = "hello"
        test1.hight = 2.3
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

        for object in objects {
            print(object.name)
        }

        XCTAssertEqual(objects.count, 11)
    }
}
