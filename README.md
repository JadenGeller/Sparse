# Sparse

Easily create dictionaries where the default value is not `nil`!
```swift
let fruitCount = Sparse(["apple": 12, "pear" : 2, "orange" : 5], defaultValue: 0)
print(fruitCount["apple"])   // -> 12
print(fruitCount["bannana"]) // -> 0
```

You can even create much more advanced mappings where the default value is a function of the key.
```swift
// Use a general heuristic basing importance off of word length
var wordImportance = Sparse<String, Int>(defaultValueForKey: { word in word.characters.count })

// Hard code the exceptions as we encounter them
wordImportance["Swift"] = 20
wordImportance["coding"] = 35

print(wordImportance["Swift"])      // -> 20
print(wordImportance["chinchilla"]) // -> 10
```

We can iterate over all the non-default (key, value) pairs in our `Sparse` as well.
```swift
for (key, value) in wordImportance {
  print(key) // -> Swift -> coding
}
```

We can also reset to default the values in a `Sparse`.
```swift
wordImportance.resetValueForKey("Swift")
```

### SparseSlice

Though `Sparse` has dictionary-like semantics, it exposes a type `SparseSlice` with array-like semantics. Perhaps you're using a `Sparse` to represent an infinite tape of memory.
```swift
let tape = Sparse<Int, Int>(defaultValue: 0)
let array = tape.slice(0..<Int.max)
for (i, x) in array.enumerate() {
  print("Memory at location \(i) equals \(x)")
}
```
Unlike `Sparse`, whose `SequenceType` conformance provides no order guarentees, `SparseSlice` can order the keys so it will iterate over them in the order you'd expect.

### Non-Equatable `Value` Types

Though `Sparse` is most eaily used with `Equatable` values, it can also be used with non-equatable values as well. When a value is not `Equatable`, you must initialize the `Sparse` with a lambda `isDefaultValueForKey` of type `Value -> Bool` that will determine whether a given value is the default.

This is particularly useful for types that are equatable for only certain values, and thus cannot conform to `Equatable`. For example, `Optional<Any -> Any>` cannot be made equatable since `Any -> Any` is not equatable, but it is trivial to see that `Optional<Any -> Any>.None == Optional<Any -> Any>.None` since this doesn't involve function comparisons. Thus, if the default value is `nil`, you can implement `isDefaultValueForKey` to make this non-equatable type work well with `Sparse`.
```swift
var efficientSparse = Sparse<Int, Optional<Any -> Any>>(defaultValue: nil, isDefaultValue: { value in
    switch value {
    case nil: return true
    default:  return false
    }
})
```

You might be wondering what the point of the `Equatable` confromance is anyhow. Well, whenever you set a key to the default value, the value is removed instead of stored as a memory optimization. You can choose to construct a Sparse without this optimization, but you will experience memory utilization more similiar to a non-sparse array when you set keys back to the default value. Note that, if you use the `resetValueForKey` function, it will *actually* remove the value and you'll get good memory utilization.
```swift
let identity: Any -> Any = { x in x }
let inefficientSparse = Sparse<Int, Any -> Any>(memoryInefficientDefultValue: identity)
for i in 0...10000 { inefficientSparse[i] = identity }       // BAD!  (stores 10,000 copies of default entry)
for i in 0...10000 { inefficientSparse.resetValueForKey(i) } // GOOD! (actually removes entries)
```
