import Deluge
import Combine
import Foundation
import Testing

func urlForResource(named resourceName: String) -> URL {
    URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent()
        .appendingPathComponent("Resources", isDirectory: true)
        .appendingPathComponent(resourceName)
}

func ensureTorrentAdded(fileURL: URL, to client: Client) -> AnyPublisher<Void, Client.Error> {
    client.request(.add(fileURL: fileURL))
        .map { _ in () }
        .replaceError(with: ())
        .setFailureType(to: Client.Error.self)
        .eraseToAnyPublisher()
}

func ensureTorrentAdded(fileURL: URL, to client: Client) async {
    do {
        try await client.request(.add(fileURL: fileURL))
    } catch {
        switch error {
        case .unknown(let unknownError):
            if case DelugeError.torrentAlreadyAddedException = unknownError {
                return
            }

            Issue.record(unknownError)
        default:
            Issue.record(error)
        }
    }
}

//// When migrated to Swift Testing: tests that use this may stomp each other
//// figure out how to fix that (or switch to swift testing???)
func ensureTorrentRemoved(hash: String, from client: Client) async throws {
    try await client.request(.remove(hashes: [hash], removeData: false))
}
