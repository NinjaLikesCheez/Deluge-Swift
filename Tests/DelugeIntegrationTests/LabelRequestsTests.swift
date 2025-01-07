import Deluge
import Combine
import Testing

@Suite("Label Requests", .serialized)
class LabelRequestsTests: IntegrationTestCase {
    @Test
    func test_setLabel() async {
        let url = urlForResource(named: TestConfig.torrent1)

        await withCheckedContinuation { continuation in
            ensureTorrentAdded(fileURL: url, to: client)
                .flatMap { _ in self.client.request(.setLabel(hash: TestConfig.torrent1Hash, label: "")) }
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
    func test_setLabel_concurrency() async throws {
        let url = urlForResource(named: TestConfig.torrent1)
        await ensureTorrentAdded(fileURL: url, to: client)
        try await client.request(.setLabel(hash: TestConfig.torrent1Hash, label: ""))
    }
}
