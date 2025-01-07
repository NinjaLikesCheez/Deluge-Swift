import Deluge
import Combine
import Testing

@Suite("Set Options Request", .serialized)
class SetOptionTests: IntegrationTestCase {
    @Test
    func test_filePriorities() async {
        let url = urlForResource(named: TestConfig.torrent1)

        await withCheckedContinuation { continuation in
            ensureTorrentAdded(fileURL: url, to: client)
                .flatMap { _ in
                    self.client.request(.setOptions(
                        hashes: [TestConfig.torrent1Hash],
                        options: [.filePriorities([.disabled])]
                    ))
                }
                .sink(
                    receiveCompletion: { completion in
                        if case let .failure(error) = completion {
                            Issue.record(error)
                        }
                        continuation.resume()
                    },
                    receiveValue: { _ in }
                )
                .store(in: &cancellables)
        }
    }

    @Test
    func test_filePriorities_concurrency() async throws {
        let url = urlForResource(named: TestConfig.torrent1)
        try await ensureTorrentAdded(fileURL: url, to: client)
        try await client.request(.setOptions(
            hashes: [TestConfig.torrent1Hash],
            options: [.filePriorities([.disabled])]
        ))
    }
}
