# MagicData

A replacement for CoreData, or Realm. It is very easy to use and is a light version.

## Support
- macOS 12 or later
- iOS 13 or later
- Linux with some settings of [SQLite](https://github.com/stephencelis/SQLite.swift/blob/master/Documentation/Linux.md) 

## Guides

### MagicData

We use **MagicData** to manage all the magic objects, which means **MagicData** can add, update, or delete the objects. All the **MagicDatas** are in the same actor thread. In this way, we keep the thread safe.

Here are some ways to create **MagicData**.
```swift
let magic = try await MagicData() // This will create a database at the app's document path
let magic = try await MagicData(path: URL(fileURLWithPath: "").path) // This will create a database at your custom path
let magic = try await MagicData(type: .temporary) // This will create a auto-delete database
let magic = try await MagicData(type: .memory) // This will create a database in the memory
```

## MagicObject

**MagicObject** is like the meaning of the table in SQLite, but it is more powerful. **MagicObject** should be a struct. But if you want to sync the non-magical value in the instance, you can choose the `class`.

```swift
struct TestModel: MagicObject {
    @PrimaryMagicValue var id: String

    @MagicValue var name: String
    @MagicValue var age: Int

    @OptionMagicValue var school: Data?
    @OptionMagicValue var petName: String?
    @OptionMagicValue var hight: Double?

    var customString: String {
        "My ID: \(id), name: \(name)"
    }

    init() {}

    init(name: String) {
        self.name = name
    }
}
```

All **MagicObjects** require the line init().
If you want to use the primary value to query the data or update the data, you need to set the `@PrimaryMagicValue`. Each **PrimaryMagicValue** has a distinct default value.
**MagicValue** has the ability to save all Magical values, which is not an option. just for the `init() {}` line. As you see, you can create an object without setting the value, but if you access the value, a crash will happen.
**OptionMagicValue** like the **MagicValue**, but it can store the option value. It has a defualt value `nil`.

Although `TestModel` is a sturct but if you copy it, and change it, the value will change in the original instance too.

```swift
let test = TestModel(name: "hi")
let test2 = test
test2.name = "hello"
print(test.name) // Hello
```

And also, if you just want to change the value of `MagicValue`, you don't need to set the `struct` as `var`.

If you gain a new instance from the database and change a value that you have had with the same primary value, the data will not sync between them.

```swift
let test = TestModel(name: "hi")
let id = test.id
magic.update(test)
let test2 = magic.object(of: TestModel.self).where { $0.id == id }
test2.name = "hello"

print(test.name) // "hi"
```

### Codable

`MagicObject` conforms to the `Codable`. However, you can never decode a `MagicObject`. `MagicObject` will be encoded to an int value that represents the object's zIndex. 

## Magical

**Magical**s are kinds of values that can be stored in the database.

Now we support theses:

* `String` will be stored as `Text` in the database.
* `UUID` will be stored as `Text` in the database.
* `Int` will be stored as `Int` in the database.
* `Double` will be stored as `Real` in the database.
* `Float` will be stored as `Real` in the database.
* `Data` will be stored as `Blob` in the database.
* `Codable` will be stored as `Blob` in the database.
* `Arrary` will be stored as `Blob` in the database.
* `Dictionary` will be stored as `Blob` in the database.
* `Set` will be stored as `Blob` in the database.

### Points of Codable

First of all, we cannot store `Codable`, but it can be stored as `MagicalCodable`. `MagicalCodable` is a variant of `Codable`.

```swift
struct Job: MagicalCodable {
    let title: String
    let salary: Int
}

@OptionMagicValue var job: Job?
```

### Ponints of Arrary & Dictionary

We only support the `Arrary` or `Dictionary` which conforms to the `Codable`.

### Primary

Some value can be used in the `@PrimaryMagicValue`:

- **String** has a defualt **UUID String** value.
- **UUID** has a default **UUID** value.
- **Int** has auto increase ability.

## MagicAsset

```swift
struct TestModel: MagicObject {
    @PrimaryMagicValue var uuid: UUID

    @MagicValue var asset: MagicAsset<String>

    init() {
        asset = .init()
    }
}
```

`MagicAsset` conforms to `Magical` too. But it only store a path in the database. It is used to save large files, the files will be saved in the local file system instead of database. The `MagicAsset`'s element need to conform the `MagicAssetConvert`. Here are the list:

* String
* Data
* MagicalCodable
* Array where Element: Codable
* Set where Element: Codable
* Dictionay where Key: Codable, Value: Codable

## AsyncMagical

`AsyncMagical` allows you don't get the value during the query, so you can get it later. It is very helpful when you save `MagicObject` or `MagicAsset`. Because it can delay the time you get the object, and speed up the time of querying.

### Support List

* MagicAsset
* Array where Element: MagicObject
* MagicalSet
* MagicObject
* Dictionay where Key: Codable, Value: MagicObject

### How to use

```swift
struct TestModel: MagicObject {
    @PrimaryMagicValue var uuid: UUID

    @MagicValue var asset: AsyncMagical<MagicAsset<String>>

    init() {}

    init(_ object: Sub) {
        asset = .init(value: object)
    }
}
```

* Get Value: `try await instanceCopy.asset.get()`
* Set Value: `instance.asset.set(.init(value: "Hello"))`

### AsyncStream

#### Support List

* Array where Element: MagicObject
* MagicalSet
* Dictionay where Key: Codable, Value: MagicObject

#### How to use

```swift
try await instance.array.randomValue()?.uuid
```

#### Random Value

#### Support List

* Array where Element: MagicObject
* MagicalSet
* Dictionay where Key: Codable, Value: MagicObject

#### How to use

```swift
for try await item in try instanceCopy.array.createAsyncStream() {
    res.append(item)
}
```

## Add/Update

```swift
try await magic.update(object)
```
If object already exits in the database or the object has a copy in the set, the set will not add the object, but will **update the object**.

## Remove

### Remove one object

```swift
try await magic.remove(test1)
```

### Remove All

```swift
try await magic.removeAll(of: TestModel.self)
```

## Query All

```swift
try await magic.object(of: TestModel.self)
```

This will give back all the values.

## Query by primary value

```swift
try await magic.object(of: TestModel.self, primary: AnyPrimaryValue)
```

This will throw an error if the primary value isn't in the database.

## Know whethere the object exits

```swift
try await magic.has(of: TestModel.self, primary: instance1.uuid)
```

**Requirement**: MagicalObject has a primary value

## Relationship

**MagicData** support relationship like core data.

### One to Many

```swift
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
```

You could use `@OptionMagicValue` as well. This kind of relationship is a little different from coredata's. because it isn't a lazy value. That means, it will fetch the `sub` in the database, when you fetch the `TestModel`.

### Many to Many

#### Set

```swift
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
```

`MagicalSet` just like a default set, but it only can store `MagicObject`.

**Although `MagicalSet` is a `Collection`, but I strongly suggest you that you shouldn't use it.**

#### Arrary

**It only supports single arrary, which means it doesn't support something like `[[MagicObject]]`**

```swift
struct TestModel: MagicObject {
    @PrimaryMagicValue var uuid: UUID

    @MagicValue var arrary: [Sub]

    init() {
        arrary = .init([])
    }
}

struct Sub: MagicObject {
    @MagicValue var text: String

    init() {}

    init(_ text: String) {
        self.text = text
    }
}
```

#### Dictionary

**It only supports single dictionaries, which means it doesn't support something like `[Int: [String: MagicObject]]`**

```swift
struct TestModel: MagicObject {
    @PrimaryMagicValue var uuid: UUID

    @MagicValue var dict: [String: Sub]

    init() {
        dict = [:]
    }
}

struct Sub: MagicObject {
    @MagicValue var text: String

    init() {}

    init(_ text: String) {
        self.text = text
    }
}
```

### Reverse

```swift
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
```

You cannot set the value of `@ReverseMagicValue`. And the `AsyncReverseMagicSet` is an `AsyncSequence`.

### Points of MagicalSet

`MagicalSet` is not a normal set. It can only promise you that it will save a set in the database and get a set from the database. But in the runtime, it can be a non-set value. 

### Insert

```swift
instance.set.insert(sub1)
```

If the object has been saved, and the set doesn't contain the value that has the same `zIndex`, the value will be insterted.
If the object hasn't been insterted, the value will always be insterted.

### Remove

```swift
instanceCopy1.set.remove(sub1)
```

Only remove the saved object that has the same `zIndex`.

```swift
instanceCopy1.set.removeAll(where perform: (Element) -> Bool)
```

You can decide which object will be removed.

### Fetch

Every time you fetch the object, we will remove the item that has the same `zIndex`. But we can not promise it in the runtime.

## What is ZIndex

ZIndex is `MagicalData`'s own primary key. It will automatically be added to your table. We use this key to judge whether the two objects are equal, or whether the object is in the database.
ZIndex is `nil` when the object hasn't saved.<br>
You cannot get the ZIndex through the `MagicalData`, but maybe we will make it public in the future.
