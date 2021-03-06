import XCTest
import Foundation
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

    func test15() async throws {
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

        let instance = TestModel()

        let sub1 = Sub("hi")
        let sub2 = sub1

        instance.set.insert(sub1)

        instance.set.insert(sub2)

        XCTAssertEqual(instance.set.count, 1)

        sub2.text = "wwdc"

        instance.set.insert(sub2)

        XCTAssertEqual(instance.set.map(\.text), ["wwdc"])
    }

    func test16() async throws {
        struct TestModel: MagicObject {
            @PrimaryMagicValue var uuid: UUID

            @MagicValue var arrary: [Sub]

            init() {
                arrary = .init([])
            }
        }

        struct Sub: MagicObject {
            @MagicValue var text: String
            @ReverseMagicValue(\TestModel.$arrary) var father: AsyncReverseMagicSet<TestModel>

            init() {}

            init(_ text: String) {
                self.text = text
            }
        }

        let instance = TestModel()

        let sub1 = Sub("hi")
        let sub2 = Sub("wwdc")

        instance.arrary.append(sub1)
        instance.arrary.append(sub2)

        let magic = try await MagicData(type: .temporary)

        try await magic.update(instance)

        let instance1 = try await magic.object(of: TestModel.self, primary: instance.uuid)

        XCTAssertEqual(instance1.arrary.count, 2)
        XCTAssertEqual(instance1.arrary.map(\.text), ["hi", "wwdc"])

        let subs = try await magic.object(of: Sub.self)
        let count = subs.count

        XCTAssertEqual(count, 2)

        let fatherCount = subs.first?.father.count

        XCTAssertEqual(fatherCount, 1)
    }

    func test17() async throws {
        struct TestModel: MagicObject {
            @PrimaryMagicValue var uuid: UUID

            @MagicValue var asset: MagicAsset<String>

            init() {
                asset = .init()
            }
        }

        let instance = TestModel()

        let magic = try await MagicData(type: .temporary)

        try await magic.update(instance)

        let instanceCopy = try await magic.object(of: TestModel.self, primary: instance.uuid)

        XCTAssertEqual(instance.asset.path, instanceCopy.asset.path)

        instanceCopy.asset.value = "hello"

        try await magic.update(instanceCopy)

        let instanceCopy2 = try await magic.object(of: TestModel.self, primary: instance.uuid)

        XCTAssertEqual(instance.asset.path, instanceCopy2.asset.path)
        XCTAssertEqual(instanceCopy2.asset.path, instanceCopy.asset.path)

        XCTAssertEqual(instanceCopy2.asset.value, "hello")
    }

    func test18() async throws {
        struct TestModel: MagicObject {
            @PrimaryMagicValue var uuid: UUID

            @MagicValue var asset: AsyncMagical<MagicAsset<String>>

            init() {
                asset = .init(value: .init())
            }
        }

        let magic = try await MagicData(type: .temporary)

        let instance = TestModel()

        instance.asset.set(.init(value: "Hello"))

        try await magic.update(instance)

        let instanceCopy = try await magic.object(of: TestModel.self, primary: instance.uuid)

        let value = try await instanceCopy.asset.get()

        XCTAssertEqual(value.value, "Hello")
    }

    func test19() async throws {
        struct TestModel: MagicObject {
            @PrimaryMagicValue var uuid: UUID

            @MagicValue var asset: AsyncMagical<Sub>

            init() {}

            init(_ object: Sub) {
                asset = .init(value: object)
            }
        }

        struct Sub: MagicObject {
            @MagicValue var text: String
            @ReverseMagicValue(\TestModel.$asset) var father: AsyncReverseMagicSet<TestModel>

            init() {}

            init(_ text: String) {
                self.text = text
            }
        }

        let magic = try await MagicData(type: .temporary)

        let instance = TestModel(Sub("hello"))

        try await magic.update(instance)

        let instanceCopy = try await magic.object(of: TestModel.self, primary: instance.uuid)

        let sub = try await instanceCopy.asset.get()

        XCTAssertEqual(sub.text, "hello")

        let subs = try await magic.object(of: Sub.self)

        XCTAssertEqual(subs.count, 1)

        let fathers = subs.first?.father

        XCTAssertEqual(fathers?.count, 1)

        for try await test in fathers ?? [] {
            XCTAssertEqual(test.uuid, instance.uuid)
        }
    }

    func test20() async throws {
        struct TestModel: MagicObject {
            @PrimaryMagicValue var uuid: UUID

            @MagicValue var asset: AsyncMagical<[Sub]>

            init() {}

            init(_ object: Sub) {
                asset = .init(value: [object])
            }
        }

        struct Sub: MagicObject {
            @MagicValue var text: String
            @ReverseMagicValue(\TestModel.$asset) var father: AsyncReverseMagicSet<TestModel>

            init() {}

            init(_ text: String) {
                self.text = text
            }
        }

        let magic = try await MagicData(type: .temporary)

        let instance = TestModel(Sub("hello"))

        try await magic.update(instance)

        let instanceCopy = try await magic.object(of: TestModel.self, primary: instance.uuid)

        let sub = try await instanceCopy.asset.get()

        XCTAssertEqual(sub.first?.text, "hello")

        let subs = try await magic.object(of: Sub.self)

        XCTAssertEqual(subs.count, 1)

        let fathers = subs.first?.father

        XCTAssertEqual(fathers?.count, 1)

        for try await test in fathers ?? [] {
            XCTAssertEqual(test.uuid, instance.uuid)
        }
    }

    func test21() async throws {
        struct TestModel: MagicObject {
            @PrimaryMagicValue var uuid: UUID

            @MagicValue var asset: AsyncMagical<MagicalSet<Sub>>

            init() {}

            init(_ object: Sub) {
                asset = .init(value: [object])
            }
        }

        struct Sub: MagicObject {
            @MagicValue var text: String
            @ReverseMagicValue(\TestModel.$asset) var father: AsyncReverseMagicSet<TestModel>

            init() {}

            init(_ text: String) {
                self.text = text
            }
        }

        let magic = try await MagicData(type: .temporary)

        let instance = TestModel(Sub("hello"))

        try await magic.update(instance)

        let instanceCopy = try await magic.object(of: TestModel.self, primary: instance.uuid)

        let sub = try await instanceCopy.asset.get()

        XCTAssertEqual(sub.map(\.text).first, "hello")

        let subs = try await magic.object(of: Sub.self)

        XCTAssertEqual(subs.count, 1)

        let fathers = subs.first?.father

        XCTAssertEqual(fathers?.count, 1)

        for try await test in fathers ?? [] {
            XCTAssertEqual(test.uuid, instance.uuid)
        }
    }

    func test22() async throws {
        struct TestModel: MagicObject {
            @PrimaryMagicValue var uuid: UUID

            @MagicValue var dict: [String : Sub]

            init() {
                dict = [:]
            }
        }

        struct Sub: MagicObject {
            @MagicValue var text: String
            @ReverseMagicValue(\TestModel.$dict) var father: AsyncReverseMagicSet<TestModel>

            init() {}

            init(_ text: String) {
                self.text = text
            }
        }

        let magic = try await MagicData(type: .temporary)

        let instance = TestModel()

        instance.dict["hi"] = Sub("wwdc")

        try await magic.update(instance)

        let instanceCopy = try await magic.object(of: TestModel.self, primary: instance.uuid)

        XCTAssertEqual(instanceCopy.dict.map({ (key: String, value: Sub) in
            return key + value.text
        }), ["hiwwdc"])

        let sub = try await magic.object(of: Sub.self).first

        XCTAssertEqual(sub?.father.count, 1)
        var uuids = [UUID]()

        for try await item in sub?.father ?? [] {
            uuids.append(item.uuid)
        }

        XCTAssertEqual(uuids, [instance.uuid])
    }

    func test23() async throws {
        struct TestModel: MagicObject {
            @PrimaryMagicValue var uuid: UUID

            @MagicValue var dict: AsyncMagical<[String : Sub]>

            init() {
                dict = .init(value: [:])
            }
        }

        struct Sub: MagicObject {
            @MagicValue var text: String
            @ReverseMagicValue(\TestModel.$dict) var father: AsyncReverseMagicSet<TestModel>

            init() {}

            init(_ text: String) {
                self.text = text
            }
        }

        let magic = try await MagicData(type: .temporary)

        let instance = TestModel()

        var dict = try await instance.dict.get()
        dict["hi"] = Sub("wwdc")
        instance.dict.set(dict)

        try await magic.update(instance)

        let instanceCopy = try await magic.object(of: TestModel.self, primary: instance.uuid)

        let arrary = try await instanceCopy.dict.get().map({ (key: String, value: Sub) in
            return key + value.text
        })

        XCTAssertEqual(arrary, ["hiwwdc"])

        let sub = try await magic.object(of: Sub.self).first

        XCTAssertEqual(sub?.father.count, 1)
        var uuids = [UUID]()

        for try await item in sub?.father ?? [] {
            uuids.append(item.uuid)
        }

        XCTAssertEqual(uuids, [instance.uuid])
    }

    func test24() async throws {
        struct TestModel: MagicObject {
            @PrimaryMagicValue var uuid: UUID

            init() {}
        }

        let magic = try await MagicData(type: .temporary)

        let res = try await magic.check(of: TestModel.self)

        XCTAssertFalse(res)
    }

    func test25() async throws {
        struct TestModel: MagicObject {
            @PrimaryMagicValue var uuid: UUID
            @MagicValue var array: AsyncMagical<[Sub]>

            init() {

            }

            init(_ array: [Sub]) {
                self.array = .init(value: array)
            }
        }

        struct Sub: MagicObject {
            @PrimaryMagicValue var uuid: UUID

            init() {}
        }

        let magic = try await MagicData(type: .temporary)

        let instance = TestModel([Sub(), Sub(), Sub()])

        XCTAssertEqual(try instance.array.count, 3)

        var _res = [Sub]()

        for try await item in try instance.array.createAsyncStream() {
            _res.append(item)
        }

        XCTAssertEqual(_res.count, 3)

        try await magic.update(instance)

        let instanceCopy = try await magic.object(of: TestModel.self, primary: instance.uuid)

        var res = [Sub]()

        for try await item in try instanceCopy.array.createAsyncStream() {
            res.append(item)
        }

        XCTAssertEqual(res.count, 3)
    }

    func test26() async throws {
        struct TestModel: MagicObject {
            @PrimaryMagicValue var uuid: UUID
            @MagicValue var array: AsyncMagical<[Int: Sub]>

            init() {

            }

            init(_ array: [Int: Sub]) {
                self.array = .init(value: array)
            }
        }

        struct Sub: MagicObject {
            @PrimaryMagicValue var uuid: UUID

            init() {}
        }

        let magic = try await MagicData(type: .temporary)

        let instance = TestModel([1: Sub(), 2: Sub(), 3: Sub()])

        var _res = [(Int, Sub)]()

        for try await item in try instance.array.createAsyncStream() {
            _res.append(item)
        }

        XCTAssertEqual(_res.count, 3)

        XCTAssertEqual(Set(_res.map(\.0)), Set([1, 2, 3]))

        try await magic.update(instance)

        let instanceCopy = try await magic.object(of: TestModel.self, primary: instance.uuid)

        var res = [(Int, Sub)]()

        for try await item in try instanceCopy.array.createAsyncStream() {
            res.append(item)
        }

        XCTAssertEqual(res.count, 3)

        XCTAssertEqual(Set(res.map(\.0)), Set([1, 2, 3]))
    }

    func test27() async throws {
        struct TestModel: MagicObject {
            @PrimaryMagicValue var uuid: UUID
            @MagicValue var array: AsyncMagical<[Sub]>

            init() {

            }

            init(_ array: [Sub]) {
                self.array = .init(value: array)
            }
        }

        struct Sub: MagicObject {
            @PrimaryMagicValue var uuid: UUID

            init() {}
        }

        let magic = try await MagicData(type: .temporary)

        let subs = [Sub(), Sub(), Sub()]

        let instance = TestModel(subs)

        let randomValue = try await instance.array.randomValue()?.uuid ?? UUID()

        XCTAssertTrue(subs.map(\.uuid).contains(randomValue))

        try await magic.update(instance)

        let instanceCopy = try await magic.object(of: TestModel.self, primary: instance.uuid)

        let randomValue1 = try await instanceCopy.array.randomValue()?.uuid ?? UUID()

        XCTAssertTrue(subs.map(\.uuid).contains(randomValue1))
    }

    func test28() async throws {
        struct TestModel: MagicObject {
            @PrimaryMagicValue var uuid: UUID
            @MagicValue var array: AsyncMagical<[Int: Sub]>

            init() {

            }

            init(_ array: [Int: Sub]) {
                self.array = .init(value: array)
            }
        }

        struct Sub: MagicObject {
            @PrimaryMagicValue var uuid: UUID

            init() {}
        }

        let magic = try await MagicData(type: .temporary)

        let subs = [1: Sub(), 2: Sub(), 3: Sub()]

        let instance = TestModel(subs)

        let randomValue = try await instance.array.randomValue()?.value.uuid ?? UUID()

        XCTAssertTrue(subs.map(\.value).map(\.uuid).contains(randomValue))

        try await magic.update(instance)

        let instanceCopy = try await magic.object(of: TestModel.self, primary: instance.uuid)

        let randomValue1 = try await instanceCopy.array.randomValue()?.value.uuid ?? UUID()

        XCTAssertTrue(subs.map(\.value).map(\.uuid).contains(randomValue1))
    }

    func test29() async throws {
        struct TestModel: MagicObject {
            @PrimaryMagicValue var uuid: UUID
            @MagicValue var array: AsyncMagical<[Sub]>

            init() {

            }

            init(_ array: [Sub]) {
                self.array = .init(value: array)
            }
        }

        struct Sub: MagicObject {
            @PrimaryMagicValue var uuid: UUID
            @MagicValue var int: Int

            init() {}

            init(_ int: Int) { self.int = int }
        }

        let magic = try await MagicData(type: .temporary)

        let instance = TestModel([Sub(1), Sub(2), Sub(3)])

        let random1 = try await instance.array.randomValue(in: 1..<2)?.int

        XCTAssertEqual(random1, 2)

        try await magic.update(instance)

        let instanceCopy = try await magic.object(of: TestModel.self, primary: instance.uuid)

        let random2 = try await instanceCopy.array.randomValue(in: 1..<2)?.int

        XCTAssertEqual(random2, 2)
    }
}
