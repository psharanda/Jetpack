# Jetpack

Jetpack is a lightweight reactive programming library for Swift. It provides tools for creating and composing asynchronous and event-based programs using observable sequences.

## Features

- Observable sequences
- Mutable and immutable property wrappers
- Combining and transforming observables 
- Threading and concurrency utilities
- Array and 2D array reactive wrappers
- Reactive subjects for broadcasting values


## Usage

```swift
import Jetpack

// Create an observable sequence
let observable = Observable.just(5)

// Subscribe to receive values
observable.subscribe { value in
    print(value) // Prints: 5
}

// Create a mutable property
let property = MutableProperty(10)

// Observe property changes
property.subscribe { value in
    print(value)
}

property.update(20) // Triggers subscription, prints: 20

// Combine observables
let combined = observable.combineLatest(property.asObservable)
combined.subscribe { (a, b) in
    print("Combined: \(a), \(b)")
}

// Transform observables
let mapped = observable.map { $0 * 2 }
mapped.subscribe { value in
    print(value) // Prints: 10
}
```

## Main Components

- `Observable`: Represents a sequence of values over time
- `Property`: Immutable wrapper around a value with reactive capabilities
- `MutableProperty`: Mutable version of Property
- `Subject`: Allows broadcasting values to multiple observers

## Threading

Jetpack provides utilities for managing concurrency:

```swift
observable.dispatch(on: .main) // Observe on main thread
observable.delay(timeInterval: 1.0, on: .global()) // Delay events
```

## Installation

### Swift Package Manager

Add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/username/Jetpack.git", from: "1.0.0")
]
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

Jetpack is released under the MIT License. See LICENSE for details.
