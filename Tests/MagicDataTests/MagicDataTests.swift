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

    func test04() async throws {
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

        let has1 = try await magic.has(of: TestModel.self, primary: instance1.uuid)
        let has2 = try await magic.has(of: TestModel.self, primary: instance2.uuid)

        XCTAssertTrue(has1)
        XCTAssertFalse(has2)
    }

    func test05() async throws {
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

        try await magic.update(instance1)

        instance1.text = "2"

        try await magic.update(instance1)

        let index = try await magic.getZIndexOfObject(instance1)

        XCTAssertEqual(index, 1)

        let instance2 = TestModel("\(UUID().uuidString)")

        try await magic.update(instance2)

        instance2.text = "2"

        try await magic.update(instance2)

        let index2 = try await magic.getZIndexOfObject(instance2)

        XCTAssertEqual(index2, 2)
    }

    func test06() async throws {
        struct TestModel: MagicObject {
            @PrimaryMagicValue var uuid: UUID

            @MagicValue var sub: Sub

            init() {}

            init(_ sub: Sub) {
                self.sub = sub
            }
        }

        struct Sub: MagicObject {
            @PrimaryMagicValue var uuid: UUID

            @MagicValue var text: String

            init() {}

            init(_ text: String) {
                self.text = text
            }
        }

        let magic = try await MagicData(type: .temporary)

        let sub1 = Sub("hi")
        let instance = TestModel(sub1)

        try await magic.update(instance)

        let first = try await magic.object(of: TestModel.self).first

        XCTAssertEqual(first?.sub.text, "hi")

        let count = try await magic.object(of: Sub.self).count

        XCTAssertEqual(count, 1)
    }
}
