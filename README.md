# MagicData

A replacement of SQlite, CoreData or Realm. It is very easy to use and is a light version.

## Guides

### MagicData

We use **MagicData** manage all the magic objects, which means **MagicData** can add, update or delete the objects. All the **MagicData**s are in the some actor thread. In this way, we keep the thread-safe.

Here are two ways to create **MagicData**.
```swift
let magic = try awiat MagicData() // This will create a database at the app's document path
let magic try await MagicData(path: URL(fileURLWithPath: "").path) // This will create a database at your custom path
```

** MagicObject

**MagicObject** is like the menaing of the table in sqlite, but it is more powerful. **MagicObject** is supposed to be a `struct`. But if you want to sync the non-magical value in the instance you can choose the `class`.

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

All **MagicObject** need a line `init() {}`.
If you want to use primary value to query the data or update the data you need to set the `@PrimaryMagicValue`. All the **PrimaryMagicValue**s have a unique defualt value.
**MagicValue** can save all the `Magical` value which it isn't option. And all the **MagicValue** have the same defualt value. But you shoudn't use them. It just for the `init() {}` line.
**OptionMagicValue** like the **MagicValue**, but it can store the option value. It has a defualt value `nil`.

Although `TestModel` is a sturct but if you copy it, and change it, the value will change in the original instance too.

```swift
let test = TestModel(name: "hi")
let test2 = test
test2.name = "hello"
print(test.name) // Hello
```

And also if you just want to change the value of `MagicValue`, you don't need to set the `struct` as `var`.

If you gain a new instance form database, and change a value that you have had with the same primary value, the data will not sync between them.

```swift
let test = TestModel(name: "hi")
let id = test.id
magic.update(test)
let test2 = magic.object(of: TestModel.self).where { $0.id == id }
test2.name = "hello"

print(test.name) // "hi"
```

## Magical

**Magical**s are kinds of values that can be stored in the database.

Now we support theses:

`String` will be stored as `Text` in the database.
`UUID` will be stored as `Text` in the database.
`Int` will be stored as `Int` in the database.
`Double` will be stored as `Real` in the database.
`Data` will be stored as `Blob` in the database.

### Primary

Some value can be used in the `@PrimaryMagicValue`:

**String** has a defualt **UUID String** value
**UUID** has a default **UUID** value
**Int** has auto increase ability.

## Add/Update

```swift
magic.update(object)
```

If object don't have primary value, every `update` is like `add`.
If object has primary, `update` or `add` will base on whether it has been stored in the database.

## Query All

```swift
magic.object(of: TestModel.self)
```

This will give back all the values.
