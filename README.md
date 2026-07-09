# Deluge

A Combine and Swift Concurrency powered Deluge JSON-RPC API client.

## Usage

### Swift Concurrency

```swift
import Deluge

let client = Deluge(baseURL: URL(string: "https://my.torrent.server")!, password: "secret!")
let authenticated = try await client.request(.authenticate(client.password))
print("Authenticated: \(authenticated)")

let hash = try await client.request(.add(magnetURL: magnetURL))
print("Added torrent with hash: \(hash)")
```

### Combine

```swift
import Combine
import Deluge

var cancellables = Set<AnyCancellable>()

let client = Deluge(baseURL: URL(string: "https://my.torrent.server")!, password: "secret!")
client.request(.authenticate(client.password))
    .sink(receiveCompletion: { _ in }, receiveValue: { _ in
        print("Authenticated!")
    })
    .store(in: &cancellables)
```

Both entry points share the same reconnect/re-authenticate retry behavior described in [AGENTS.md](AGENTS.md).

## Requests

A `DelugeRequest` describes an RPC method, its arguments, and a function to transform the API response in to a new representation.

There are many requests already built-in. To see the available requests you can take a look at the [Requests](Sources/Deluge/Requests/) directory or browse through the autocomplete menu when typing `client.request(.`.

```swift
extension DelugeRequest<String> {
    static func addMagnetURL(_ magnetURL: URL) -> DelugeRequest<String> {
        DelugeRequest(method: "core.add_torrent_magnet", args: [magnetURL.absoluteString, [String: Any]()]) { data in
            let response = try JSONDecoder().decode(Deluge.Response<String>.self, from: data)
            return response.result
        }
    }
}
```

## Installation

### Swift Package Manager

Add the package to your `Package.swift` dependencies:

```swift
.package(url: "https://github.com/NinjaLikesCheez/Deluge-Swift.git", from: "2.0.0")
```

Or in Xcode: **File** > **Add Package Dependencies...**, then enter `https://github.com/NinjaLikesCheez/Deluge-Swift.git`.

## License

This library is released under the MIT license. See [LICENSE](LICENSE) for details.
