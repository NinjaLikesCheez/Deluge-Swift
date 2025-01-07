import Deluge
import Combine
import Foundation
import Testing

@Suite("Core Requests", .serialized)
class CoreRequestsTests: IntegrationTestCase {
    @Test
    func test_addFileURL() async throws {
        let url = urlForResource(named: TestConfig.torrent2)

        try await ensureTorrentRemoved(hash: TestConfig.torrent2Hash, from: client)

        await withCheckedContinuation { continuation in
            client.request(.add(fileURL: url))
                .sink(
                    receiveCompletion: { completion in
                        if case let .failure(error) = completion {
                            Issue.record(error)
                        } else {
                            continuation.resume()
                        }
                    },
                    receiveValue: { hash in
                        #expect(hash == TestConfig.torrent2Hash)
                    }
                )
                .store(in: &cancellables)
        }
    }

    @Test
    func test_addFileURL_concurrency() async throws {
        let url = urlForResource(named: TestConfig.torrent2)
        try await ensureTorrentRemoved(hash: TestConfig.torrent2Hash, from: client)
        let hash = try await client.request(.add(fileURL: url))

        #expect(hash == TestConfig.torrent2Hash)
    }

    @Test
    func test_addFileURLs() async throws {
        let urls = [
            urlForResource(named: TestConfig.torrent3),
            urlForResource(named: TestConfig.torrent4),
        ]

        try await ensureTorrentRemoved(hash: TestConfig.torrent3Hash, from: client)
        try await ensureTorrentRemoved(hash: TestConfig.torrent4Hash, from: client)

        await withCheckedContinuation { continuation in
            client.request(.add(fileURLs: urls))
                .sink(
                    receiveCompletion: { completion in
                        if case let .failure(error) = completion {
                            Issue.record(error)
                        } else {
                            continuation.resume()
                        }
                    },
                    receiveValue: { _ in }
                )
                .store(in: &cancellables)
        }
    }

    @Test
    func test_addFileURLs_concurrency() async throws {
        let urls = [
            urlForResource(named: TestConfig.torrent3),
            urlForResource(named: TestConfig.torrent4),
        ]

        try await ensureTorrentRemoved(hash: TestConfig.torrent3Hash, from: client)
        try await ensureTorrentRemoved(hash: TestConfig.torrent4Hash, from: client)

        try await client.request(.add(fileURLs: urls))
    }

    @Test
    func test_addMagnetURL() async throws {
        let url = URL(string: TestConfig.magnetURL)!
        try await ensureTorrentRemoved(hash: TestConfig.magnetHash, from: client)

        await withCheckedContinuation { continuation in
            client.request(.add(magnetURL: url))
                .sink(
                    receiveCompletion: { completion in
                        if case let .failure(error) = completion {
                            Issue.record(error)
                        }

                        continuation.resume()
                    },
                    receiveValue: { hash in
                        #expect(hash == TestConfig.magnetHash)
                    }
                )
                .store(in: &cancellables)
        }
    }

    @Test
    func test_addMagnetURL_concurrency() async throws {
        let url = URL(string: TestConfig.magnetURL)!
        try await ensureTorrentRemoved(hash: TestConfig.magnetHash, from: client)

        let hash = try await client.request(.add(magnetURL: url))
        #expect(hash == TestConfig.magnetHash)
    }

    @Test
    func test_addURL() async throws {
        let url = URL(string: TestConfig.webURL)!

        try await ensureTorrentRemoved(hash: TestConfig.webURLHash, from: client)

        await withCheckedContinuation { continuation in
            client.request(.add(url: url))
                .sink(
                    receiveCompletion: { completion in
                        if case let .failure(error) = completion {
                            Issue.record(error)
                        } else {
                            continuation.resume()
                        }
                    },
                    receiveValue: { _ in }
                )
                .store(in: &cancellables)
        }
    }

    @Test
    func test_addURL_concurrency() async throws {
        let url = URL(string: TestConfig.webURL)!
        try await ensureTorrentRemoved(hash: TestConfig.webURLHash, from: client)
        try await client.request(.add(url: url))
    }

    @Test
    func test_reannounce() async {
        let url = urlForResource(named: TestConfig.torrent1)

        await withCheckedContinuation { continuation in
            ensureTorrentAdded(fileURL: url, to: client)
                .flatMap { _ in self.client.request(.reannounce(hashes: [TestConfig.torrent1Hash])) }
                .sink(
                    receiveCompletion: { completion in
                        if case let .failure(error) = completion {
                            Issue.record(error)
                        } else {
                            continuation.resume()
                        }
                    },
                    receiveValue: { _ in }
                )
                .store(in: &cancellables)
        }
    }

    @Test
    func test_reannounce_concurrency() async throws {
        let url = urlForResource(named: TestConfig.torrent1)
        await ensureTorrentAdded(fileURL: url, to: client)
        try await client.request(.reannounce(hashes: [TestConfig.torrent1Hash]))
    }

    @Test
    func test_recheck() async {
        let url = urlForResource(named: TestConfig.torrent1)

        await withCheckedContinuation { continuation in
            ensureTorrentAdded(fileURL: url, to: client)
                .flatMap { _ in self.client.request(.recheck(hashes: [TestConfig.torrent1Hash])) }
                .sink(
                    receiveCompletion: { completion in
                        if case let .failure(error) = completion {
                            Issue.record(error)
                        } else {
                            continuation.resume()
                        }
                    },
                    receiveValue: { _ in }
                )
                .store(in: &cancellables)
        }
    }

    @Test
    func test_recheck_concurrency() async throws {
        let url = urlForResource(named: TestConfig.torrent1)
        await ensureTorrentAdded(fileURL: url, to: client)
        try await client.request(.recheck(hashes: [TestConfig.torrent1Hash]))
    }

    @Test
    func test_move() async throws {
        let url = urlForResource(named: TestConfig.torrent1)

        await withCheckedContinuation { continuation in
            ensureTorrentAdded(fileURL: url, to: client)
                .flatMap { _ in self.client.request(.move(hashes: [TestConfig.torrent1Hash], path: "/tmp")) }
                .sink(
                    receiveCompletion: { completion in
                        if case let .failure(error) = completion {
                            Issue.record(error)
                        } else {
                            continuation.resume()
                        }
                    },
                    receiveValue: { _ in }
                )
                .store(in: &cancellables)
        }
    }

    @Test
    func test_move_concurrency() async throws {
        let url = urlForResource(named: TestConfig.torrent1)
        await ensureTorrentAdded(fileURL: url, to: client)
        try await client.request(.move(hashes: [TestConfig.torrent1Hash], path: "/tmp"))
    }

    @Test
    func test_removeTorrents_error() async {
        await withCheckedContinuation { continuation in
            client.request(.remove(hashes: ["a"], removeData: false))
                .sink(
                    receiveCompletion: { completion in
                        if case let .failure(error) = completion {
                            Issue.record(error)
                        }
                    },
                    receiveValue: { errors in
                        #expect(errors.count == 1)
                        #expect(errors.first?.hash == "a")
                        continuation.resume()
                    }
                )
                .store(in: &cancellables)
        }
    }

    @Test
    func test_removeTorrents_error_concurrency() async throws {
        let errors = try await client.request(.remove(hashes: ["a"], removeData: false))
        #expect(errors.count == 1)
        #expect(errors.first?.hash == "a")
    }

    @Test
    func test_pause() async {
        let url = urlForResource(named: TestConfig.torrent1)

        await withCheckedContinuation { continuation in
            ensureTorrentAdded(fileURL: url, to: client)
                .flatMap { _ in self.client.request(.pause(hashes: [TestConfig.torrent1Hash])) }
                .sink(
                    receiveCompletion: { completion in
                        if case let .failure(error) = completion {
                            Issue.record(error)
                        } else {
                            continuation.resume()
                        }
                    },
                    receiveValue: { _ in }
                )
                .store(in: &cancellables)

        }
    }

    @Test
    func test_pause_concurrency() async throws {
        let url = urlForResource(named: TestConfig.torrent1)
        await ensureTorrentAdded(fileURL: url, to: client)
        try await client.request(.pause(hashes: [TestConfig.torrent1Hash]))
    }

    @Test
    func test_resume() async {
        let url = urlForResource(named: TestConfig.torrent1)

        await withCheckedContinuation { continuation in
            ensureTorrentAdded(fileURL: url, to: client)
                .flatMap { _ in self.client.request(.resume(hashes: [TestConfig.torrent1Hash])) }
                .sink(
                    receiveCompletion: { completion in
                        if case let .failure(error) = completion {
                            Issue.record(error)
                        } else {
                            continuation.resume()
                        }
                    },
                    receiveValue: { _ in }
                )
                .store(in: &cancellables)
        }
    }

    @Test
    func test_resume_concurrency() async throws {
        let url = urlForResource(named: TestConfig.torrent1)
        await ensureTorrentAdded(fileURL: url, to: client)
        try await client.request(.resume(hashes: [TestConfig.torrent1Hash]))
    }
}
