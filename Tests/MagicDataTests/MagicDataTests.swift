import XCTest
@testable import MagicData

final class MagicDataTests: XCTestCase {
    func test01() async throws {
        struct TestModel: MagicObject {
            @PrimaryMagicValue var uuid: UUID

            @MagicValue var text: String

            @OptionMagicValue var value: Int?

            init() {}

            init(_ text: String) {
                self.text = text
            }
        }

        let magic = try await MagicData(type: .temporary)

        let count = try await magic.object(of: TestModel.self).count

        XCTAssertEqual(count, 0)

        let instance = TestModel("1")
        instance.value = 1
        let instance2 = instance
        instance2.text = "2"

        XCTAssertEqual(instance.text, "2")

        try await magic.update(instance)

        let objects = try await magic.object(of: TestModel.self)

        XCTAssertEqual(objects.count, 1)

        XCTAssertEqual(objects.first?.value, 1)
        XCTAssertEqual(objects.first?.text, "2")
    }

    func test02() async throws {
        struct TestModel: MagicObject {
            @MagicValue var text: String

            @OptionMagicValue var value: Int?

            init() {}

            init(_ text: String) {
                self.text = text
            }
        }

        let instance = TestModel("1")

        XCTAssertFalse(instance.hasPrimaryValue)
    }

    func test03() async throws {
        struct TestModel: MagicObject {
            @PrimaryMagicValue var uuid: UUID

            @MagicValue var text: String

            init() {}

            init(_ text: String) {
                self.text = text
            }
        }

        let magic = try await MagicData(type: .temporary)

        let instance1 = TestModel("\(UUID().uuidString)")
        let instance2 = TestModel("\(UUID().uuidString)")

        try await magic.update(instance1)
        try await magic.update(instance2)

        let count = try await magic.object(of: TestModel.self).count

        XCTAssertEqual(count, 2)

        let instance1Copy = try await magic.object(of: TestModel.self, primary: instance1.uuid)

        XCTAssertEqual(instance1Copy.text, instance1.text)
    }

}
