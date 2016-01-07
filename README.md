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

Though `Sparse` has dictionary-like semantics, it exposes a type `SparseSlice` with array-like semantics. Perhaps you're using a `Sparse` to represent an infinite tape of memory.
```swift
let tape = Sparse<Int, Int>(defaultValue: 0)
let array = tape.slice(0..<Int.max)
for (i, x) in array.enumerate() {
  print("Memory at location \(i) equals \(x)")
}
```
Unlike `Sparse`, whose `SequenceType` conformance provides no order guarentees, `SparseSlice` can order the keys so it will iterate over them in the order you'd expect.

Though `Sparse` is most eaily used with `Equatable` values, it can also be used with non-equatable values as well. As an optimization, `Sparse` removes a value from storage when it is set to the default. If you'd like to use a sparse with a value that absolutely cannot be equatable, initialize `Sparse` with a "neverEquatable" `EquatableValue`.
```swift
typealias Function = Any -> Any
let identity: Function = { x in x }
var inefficientSparse = Sparse<Int, Function>(defaultValue: EquatableValue(neverEquatable: identity))
```
This sparse can be used completely normally, but it will continue to grow in size as more and more keys are set to the default value.
```swift
for i in 0...10000 { inefficientSparse[i] = identity }       // memory-intensive for a "neverEquatable" value!!
for i in 0...10000 { inefficientSparse.resetValueForKey(i) } // this operation actually releases the memory as expected
```
If you're working with a type that cannot be made *fully* equatable, but it is always possible to check if a given value is the default or not, you *can* take advantage of this optimization! `EquatableValue` provides an initializer takes a closure that, given a value, determines if it is the default value. So even if you're working with `Optional<Blah>` for non-optional type `Blah`, if you're default value is `nil` you can use the optimization.
```swift
var efficientSparse = Sparse<Int, Function>(defaultValue: EquatableValue(value: nil, isValue: { value in
  switch value {
  case nil: return true
  defualt:  return false
  }
})
```
Since this is a common pattern, you can actually use `EquatableValue.None` for a `nil` or a `[]` default value.
