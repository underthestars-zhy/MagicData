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

        let sub2 = Sub("hello")
        instance.sub = sub2

        try await magic.update(instance)

        let first1 = try await magic.object(of: TestModel.self).first

        XCTAssertEqual(first1?.sub.text, "hello")

        let count2 = try await magic.object(of: Sub.self).count

        XCTAssertEqual(count2, 2)
    }

    func test07() async throws {
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

    func test08() async throws {
        struct TestModel: MagicObject {
            @PrimaryMagicValue var uuid: UUID

            @MagicValue var set: Set<String>

            init() {
                set = []
            }
        }

        let magic = try await MagicData(type: .temporary)

        let instance = TestModel()

        instance.set.insert("hi")
        instance.set.insert("hello")

        try await magic.update(instance)

        let first = try await magic.object(of: TestModel.self).first

        XCTAssertEqual(first?.set, ["hi", "hello"])

        instance.set.remove("hi")

        try await magic.update(instance)

        let second = try await magic.object(of: TestModel.self).first

        XCTAssertEqual(second?.set, ["hello"])
    }

    func test09() async throws {
        struct TestModel: MagicObject {
            @PrimaryMagicValue var uuid: UUID

            @MagicValue var set: MagicalSet<Sub>

            init() {
                set = .init([])
            }
        }

        struct Sub: MagicObject {
            @MagicValue var text: String

            init() {}

            init(_ text: String) {
                self.text = text
            }
        }

        let magic = try await MagicData(type: .memory)

        let instance = TestModel()

        let sub1 = Sub("hello")
        let sub2 = Sub("hi")

        instance.set.insert(sub1)
        instance.set.insert(sub2)

        try await magic.update(instance)

        let instanceCopy1 = try await magic.object(of: TestModel.self, primary: instance.uuid)

        XCTAssertEqual(Set(instanceCopy1.set.map(\.text)), Set([sub1, sub2].map(\.text)))

        instanceCopy1.set.remove(sub1)

        try await magic.update(instanceCopy1)

        let instanceCopy2 = try await magic.object(of: TestModel.self, primary: instance.uuid)

        XCTAssertEqual(instanceCopy2.set.map(\.text), [sub2].map(\.text))
    }

    func test10() async throws {
        struct Sub: MagicObject {
            @MagicValue var text: String

            init() {}

            init(_ text: String) {
                self.text = text
            }
        }

        let magic = try await MagicData(type: .memory)

        let sub1 = Sub("hello")

        try await magic.update(sub1)

        sub1.text = "hi"

        try await magic.update(sub1)

        let count = try await magic.object(of: Sub.self).count

        XCTAssertEqual(count, 1)

        try await magic.update(Sub("ohh"))

        let count1 = try await magic.object(of: Sub.self).count

        XCTAssertEqual(count1, 2)
    }

    func test12() async throws {
        struct TestModel: MagicObject {
            @PrimaryMagicValue var uuid: UUID

            @MagicValue var set: MagicalSet<Sub>

            init() {
                set = .init([])
            }
        }

        struct Sub: MagicObject {
            @MagicValue var text: String
            @ReverseMagicValue(\TestModel.$set) var father: AsyncReverseMagicSet<TestModel>

            init() {}

            init(_ text: String) {
                self.text = text
            }
        }

        let magic = try await MagicData(type: .memory)

        let sub1 = Sub("hi")
        let sub2 = Sub("hello")

        let instance = TestModel()
        instance.set.insert(sub1)
        instance.set.insert(sub2)

        try await magic.update(instance)

        let subs = try await magic.object(of: Sub.self)
        let sub3 = subs.first
        XCTAssertEqual(subs.count, 2)

        let sub3Fathers = sub3?.father

        XCTAssertEqual(sub3Fathers?.count, 1)

        let instance2 = TestModel()
        instance2.set.insert(sub1)
        instance2.set.insert(sub2)

        try await magic.update(instance2)

        let subs2 = try await magic.object(of: Sub.self)
        let sub4 = subs2.first
        XCTAssertEqual(subs2.count, 2)

        let sub4Fathers = sub4?.father

        XCTAssertEqual(sub4Fathers?.count, 2)
    }

    func test14() async throws {
        struct TestModel: MagicObject {
            @PrimaryMagicValue var uuid: UUID

            init() {

            }
        }

        let test1 = TestModel()
        let test2 = TestModel()

        let magic = try await MagicData(type: .temporary)

        try await magic.update(test1)
        try await magic.update(test2)

        let count = try await magic.object(of: TestModel.self).count

        XCTAssertEqual(count, 2)

        try await magic.remove(test1)

        let count1 = try await magic.object(of: TestModel.self).count

        XCTAssertEqual(count1, 1)

        try await magic.removeAll(of: TestModel.self)

        let count2 = try await magic.object(of: TestModel.self).count

        XCTAssertEqual(count2, 0)
    }
}
