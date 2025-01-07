import Deluge
import Combine
import Testing

@Suite("Web Requests", .serialized)
class WebRequestsTests: IntegrationTestCase {
    @Test
    func test_updateUI() async {
        let url = urlForResource(named: TestConfig.torrent1)

        await withCheckedContinuation { continuation in
            ensureTorrentAdded(fileURL: url, to: client)
                .flatMap { _ in self.client.request(.updateUI(properties: Torrent.PropertyKeys.allCases)) }
                .sink(
                    receiveCompletion: { completion in
                        if case let .failure(error) = completion {
                            Issue.record(error)
                        }
                        continuation.resume()
                    },
                    receiveValue: { state in
                        let torrent = state.torrents.first(where: { $0.hash == TestConfig.torrent1Hash })
                        #expect(torrent?.dateAdded != nil)
                        #expect(torrent?.downloaded != nil)
                        #expect(torrent?.downloadPath != nil)
                        #expect(torrent?.downloadRate != nil)
                        #expect(torrent?.eta != nil)
                        #expect(torrent?.label != nil)
                        #expect(torrent?.name != nil)
                        #expect(torrent?.peers != nil)
                        #expect(torrent?.progress != nil)
                        #expect(torrent?.seeds != nil)
                        #expect(torrent?.size != nil)
                        #expect(torrent?.state != nil)
                        #expect(torrent?.totalPeers != nil)
                        #expect(torrent?.totalSeeds != nil)
                        #expect(torrent?.trackers == TestConfig.torrent1Trackers)
                        #expect(torrent?.uploadRate != nil)
                        #expect(torrent?.uploadRate != nil)
                    }
                )
                .store(in: &cancellables)
        }
    }

    @Test
    func test_updateUI_concurrency() async throws {
        let url = urlForResource(named: TestConfig.torrent1)
        try await ensureTorrentAdded(fileURL: url, to: client)
        let state = try await client.request(.updateUI(properties: Torrent.PropertyKeys.allCases))
        let torrent = state.torrents.first(where: { $0.hash == TestConfig.torrent1Hash })

        #expect(torrent?.dateAdded != nil)
        #expect(torrent?.downloaded != nil)
        #expect(torrent?.downloadPath != nil)
        #expect(torrent?.downloadRate != nil)
        #expect(torrent?.eta != nil)
        #expect(torrent?.label != nil)
        #expect(torrent?.name != nil)
        #expect(torrent?.peers != nil)
        #expect(torrent?.progress != nil)
        #expect(torrent?.seeds != nil)
        #expect(torrent?.size != nil)
        #expect(torrent?.state != nil)
        #expect(torrent?.totalPeers != nil)
        #expect(torrent?.totalSeeds != nil)
        #expect(torrent?.trackers == TestConfig.torrent1Trackers)
        #expect(torrent?.uploadRate != nil)
        #expect(torrent?.uploadRate != nil)
    }

    @Test
    func test_torrentItems() async {
        let url = urlForResource(named: TestConfig.torrent1)

        await withCheckedContinuation { continuation in
            ensureTorrentAdded(fileURL: url, to: client)
                .flatMap { _ in self.client.request(.torrentItems(hash: TestConfig.torrent1Hash)) }
                .sink(
                    receiveCompletion: { completion in
                        if case let .failure(error) = completion {
                            Issue.record(error)
                        }
                        continuation.resume()
                    },
                    receiveValue: { items in
                        #expect(items.count == 1)
                        guard case let .file(file) = items.first else {
                            Issue.record("Unexpected item: \(String(describing: items.first))")
                            return
                        }
                        #expect(file.name == TestConfig.torrent1FileName)
                    }
                )
                .store(in: &cancellables)
        }
    }

    @Test
    func test_torrentItems_concurrency() async throws {
        let url = urlForResource(named: TestConfig.torrent1)
        try await ensureTorrentAdded(fileURL: url, to: client)
        _ = try await client.request(.authenticate(TestConfig.serverPassword))

        let items = try await client.request(.torrentItems(hash: TestConfig.torrent1Hash))
        #expect(items.count == 1)
        guard case let .file(file) = items.first else {
            Issue.record("Unexpected item: \(String(describing: items.first))")
            return
        }
        #expect(file.name == TestConfig.torrent1FileName)
    }
}
