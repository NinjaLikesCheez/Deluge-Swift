import Deluge
import Foundation
import Logging
import Testing

#if canImport(Combine)
	import Combine
#endif

@Suite("Web Requests", .serialized)
struct WebRequestsTests {
	#if canImport(Combine)
		@Test
		func test_updateUI() async throws {
			let url = urlForResource(named: TestConfig.torrent1)
			try await ensureTorrentAdded(fileURL: url, to: client)
			try #require(try await ensurePluginEnabled(.label, from: client), "Label plugin could not be enabled")
			for try await state in client.request(.updateUI(properties: Torrent.PropertyKeys.allCases)).values {
				#expect(state.connected == true)
				let torrent = state.torrents.first(where: { $0.hash == TestConfig.torrent1Hash })
				#expect(torrent?.activeTime != nil)
				#expect(torrent?.autoManaged != nil)
				#expect(torrent?.completedTime != nil)
				#expect(torrent?.comment != nil)
				#expect(torrent?.creator != nil)
				#expect(torrent?.dateAdded != nil)
				#expect(torrent?.distributedCopies != nil)
				#expect(torrent?.downloaded != nil)
				#expect(torrent?.downloadPath != nil)
				#expect(torrent?.downloadRate != nil)
				#expect(torrent?.eta != nil)
				#expect(torrent?.filePriorities != nil)
				#expect(torrent?.finishedTime != nil)
				#expect(torrent?.isFinished != nil)
				#expect(torrent?.isPrivate != nil)
				#expect(torrent?.label != nil)
				#expect(torrent?.maxDownloadSpeed != nil)
				#expect(torrent?.maxUploadSpeed != nil)
				#expect(torrent?.moveCompletedPath != nil)
				#expect(torrent?.name != nil)
				#expect(torrent?.numFiles != nil)
				#expect(torrent?.peers != nil)
				#expect(torrent?.progress != nil)
				#expect(torrent?.queue != nil)
				#expect(torrent?.ratio != nil)
				#expect(torrent?.seeds != nil)
				#expect(torrent?.seedingTime != nil)
				#expect(torrent?.size != nil)
				#expect(torrent?.state != nil)
				#expect(torrent?.totalPeers != nil)
				#expect(torrent?.totalSeeds != nil)
				#expect(torrent?.tracker != nil)
				#expect(torrent?.trackerHost != nil)
				#expect(torrent?.trackerStatus != nil)
				#expect(torrent?.trackers == TestConfig.torrent1Trackers)
				#expect(torrent?.uploaded != nil)
				#expect(torrent?.uploadRate != nil)
			}
		}

		@Test
		func test_torrentItems() async throws {
			let url = urlForResource(named: TestConfig.torrent1)
			try await ensureTorrentAdded(fileURL: url, to: client)
			for try await items in client.request(.torrentItems(hash: TestConfig.torrent1Hash)).values {
				#expect(items.count == 1)
				guard case let .file(file) = items.first else {
					Issue.record("Unexpected item: \(String(describing: items.first))")
					return
				}
				#expect(file.name == TestConfig.torrent1FileName)
			}
		}
	#endif

	@Test
	func test_updateUI_concurrency() async throws {
		let url = urlForResource(named: TestConfig.torrent1)
		try #require(try await ensurePluginEnabled(.label, from: client), "Label plugin could not be enabled")
		try await ensureTorrentAdded(fileURL: url, to: client)
		let state = try await client.request(.updateUI(properties: Torrent.PropertyKeys.allCases))
		#expect(state.connected == true)

		let torrent = state.torrents.first(where: { $0.hash == TestConfig.torrent1Hash })

		#expect(torrent?.activeTime != nil)
		#expect(torrent?.autoManaged != nil)
		#expect(torrent?.completedTime != nil)
		#expect(torrent?.comment != nil)
		#expect(torrent?.creator != nil)
		#expect(torrent?.dateAdded != nil)
		#expect(torrent?.distributedCopies != nil)
		#expect(torrent?.downloaded != nil)
		#expect(torrent?.downloadPath != nil)
		#expect(torrent?.downloadRate != nil)
		#expect(torrent?.eta != nil)
		#expect(torrent?.filePriorities != nil)
		#expect(torrent?.finishedTime != nil)
		#expect(torrent?.isFinished != nil)
		#expect(torrent?.isPrivate != nil)
		#expect(torrent?.label != nil)
		#expect(torrent?.maxDownloadSpeed != nil)
		#expect(torrent?.maxUploadSpeed != nil)
		#expect(torrent?.moveCompletedPath != nil)
		#expect(torrent?.name != nil)
		#expect(torrent?.numFiles != nil)
		#expect(torrent?.peers != nil)
		#expect(torrent?.progress != nil)
		#expect(torrent?.queue != nil)
		#expect(torrent?.ratio != nil)
		#expect(torrent?.seeds != nil)
		#expect(torrent?.seedingTime != nil)
		#expect(torrent?.size != nil)
		#expect(torrent?.state != nil)
		#expect(torrent?.totalPeers != nil)
		#expect(torrent?.totalSeeds != nil)
		#expect(torrent?.tracker != nil)
		#expect(torrent?.trackerHost != nil)
		#expect(torrent?.trackerStatus != nil)
		#expect(torrent?.trackers == TestConfig.torrent1Trackers)
		#expect(torrent?.uploaded != nil)
		#expect(torrent?.uploadRate != nil)
	}

	@Test
	func test_torrentItems_concurrency() async throws {
		let url = urlForResource(named: TestConfig.torrent1)
		try await ensureTorrentAdded(fileURL: url, to: client)

		let items = try await client.request(.torrentItems(hash: TestConfig.torrent1Hash))
		#expect(items.count == 1)
		guard case let .file(file) = items.first else {
			Issue.record("Unexpected item: \(String(describing: items.first))")
			return
		}
		#expect(file.name == TestConfig.torrent1FileName)
	}

	@Test
	func test_plugins_concurrency() async throws {
		let plugins = try await client.request(.plugins)
		#expect(plugins.available.count == 10)
	}

	@Test
	func test_reconnect_when_disconnected() async throws {
		_ = try? await client.request(.disconnect)
		var connected = try await client.request(.connected)
		#expect(connected == false)

		try await client.request(.updateUI(properties: Torrent.PropertyKeys.allCases))

		connected = try await client.request(.connected)
		#expect(connected == true)
	}

	@Test
	func test_torrentStatus_concurrency() async throws {
		// The web client's session proxy caches torrent status per-connection and only learns about a torrent via
		// `TorrentAddedEvent`. If a previous test (e.g. `test_reconnect_when_disconnected`) left the connection
		// freshly re-established, the proxy's cache can be empty even though the torrent is already in the daemon's
		// session - so remove and re-add the torrent here to guarantee the proxy observes it.
		try await ensureTorrentRemoved(hash: TestConfig.torrent1Hash, from: client)
		let url = urlForResource(named: TestConfig.torrent1)
		try await ensureTorrentAdded(fileURL: url, to: client)

		var torrent: Torrent?
		for _ in 0..<10 {
			let candidate = try await client.request(
				.torrentStatus(hash: TestConfig.torrent1Hash, properties: Torrent.PropertyKeys.allCases)
			)
			if candidate.name != nil {
				torrent = candidate
				break
			}
			try await Task.sleep(for: .milliseconds(100))
		}

		let unwrappedTorrent = try #require(torrent)
		#expect(unwrappedTorrent.hash == TestConfig.torrent1Hash)
		#expect(unwrappedTorrent.name != nil)
		#expect(unwrappedTorrent.size != nil)
	}

	@Test
	func test_downloadTorrent_getTorrentInfo_concurrency() async throws {
		let url = URL(string: TestConfig.webURL)!
		let filename = try await client.request(.downloadTorrent(fromURL: url))
		#expect(!filename.isEmpty)

		let info = try await client.request(.torrentInfo(filename: filename))
		#expect(info?.infoHash == TestConfig.webURLHash)
	}

	@Test
	func test_getTorrentInfo_invalidFile_concurrency() async throws {
		let info = try await client.request(.torrentInfo(filename: "/tmp/does-not-exist-\(UUID()).torrent"))
		#expect(info == nil)
	}

	@Test
	func test_getMagnetInfo_concurrency() async throws {
		let info = try await client.request(.magnetInfo(uri: TestConfig.magnetURL))
		#expect(info?.infoHash == TestConfig.magnetHash)
	}

	@Test
	func test_getMagnetInfo_invalidURI_concurrency() async throws {
		let info = try await client.request(.magnetInfo(uri: "not-a-magnet-uri"))
		#expect(info == nil)
	}

	@Test
	func test_addTorrents_concurrency() async throws {
		try await ensureTorrentRemoved(hash: TestConfig.magnetHash, from: client)

		try await client.request(.addTorrents([.init(path: TestConfig.magnetURL)]))

		let state = try await client.request(.updateUI(properties: Torrent.PropertyKeys.allCases))
		#expect(state.torrents.contains(where: { $0.hash == TestConfig.magnetHash }))
	}

	@Test
	func test_addHost_getHostStatus_editHost_removeHost_concurrency() async throws {
		let result = try await client.request(.addHost(host: "127.0.0.1", port: 58846, username: "test-user"))
		guard case let .success(hostID) = result else {
			Issue.record("Expected success, got \(result)")
			return
		}

		let status = try await client.request(.hostStatus(hostID: hostID))
		#expect(status.id == hostID)

		let edited = try await client.request(
			.editHost(hostID: hostID, host: "127.0.0.1", port: 58846, username: "test-user-2")
		)
		#expect(edited == true)

		let removed = try await client.request(.removeHost(hostID: hostID))
		#expect(removed == true)
	}

	@Test
	func test_addHost_invalid_concurrency() async throws {
		let result = try await client.request(.addHost(host: "", port: -1))
		guard case .failure = result else {
			Issue.record("Expected failure, got \(result)")
			return
		}
	}

	@Test
	func test_removeHost_nonexistent_concurrency() async throws {
		let removed = try await client.request(.removeHost(hostID: "nonexistent"))
		#expect(removed == false)
	}

	@Test
	func test_webConfig_concurrency() async throws {
		let config = try await client.request(.webConfig)
		#expect(config["port"] != nil)
	}

	@Test
	func test_setWebConfig_concurrency() async throws {
		let config = try await client.request(.webConfig)
		guard case let .bool(showSidebar)? = config["show_sidebar"] else {
			Issue.record("Expected `show_sidebar` to be a bool")
			return
		}

		try await client.request(.setWebConfig(["show_sidebar": .bool(!showSidebar)]))

		let updatedConfig = try await client.request(.webConfig)
		#expect(updatedConfig["show_sidebar"] == .bool(!showSidebar))

		try await client.request(.setWebConfig(["show_sidebar": .bool(showSidebar)]))
	}

	@Test
	func test_pluginInfo_concurrency() async throws {
		let info = try await client.request(.pluginInfo(name: "Label"))
		#expect(!info.isEmpty)
	}

	@Test
	func test_registerAndDeregisterEventListener_concurrency() async throws {
		try await client.request(.registerEventListener(event: "TorrentAddedEvent"))
		try await client.request(.deregisterEventListener(event: "TorrentAddedEvent"))
	}

	@Test
	func test_languages_concurrency() async throws {
		let languages = try await client.request(.languages)
		#expect(!languages.isEmpty)
		#expect(languages.allSatisfy { $0.count == 2 })
	}
}
