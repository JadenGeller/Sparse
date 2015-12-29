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
