import Deluge
import Foundation
import Testing

#if canImport(Combine)
	import Combine
#endif

@Suite("Core Requests", .serialized)
struct CoreRequestsTests {
	#if canImport(Combine)
		@Test
		func test_addFileURL() async throws {
			let url = urlForResource(named: TestConfig.torrent2)

			try await ensureTorrentRemoved(hash: TestConfig.torrent2Hash, from: client)

			try await confirmation { confirmation in
				for try await hash in client.request(.add(fileURL: url)).values {
					#expect(hash == TestConfig.torrent2Hash)
					confirmation.confirm()
				}
			}
		}

		@Test
		func test_addFileURLs() async throws {
			let urls = [
				urlForResource(named: TestConfig.torrent3),
				urlForResource(named: TestConfig.torrent4),
			]

			try await ensureTorrentRemoved(hash: TestConfig.torrent3Hash, from: client)
			try await ensureTorrentRemoved(hash: TestConfig.torrent4Hash, from: client)

			for try await _ in client.request(.add(fileURLs: urls)).values {}
		}

		@Test
		func test_addMagnetURL() async throws {
			let url = URL(string: TestConfig.magnetURL)!

			try await ensureTorrentRemoved(hash: TestConfig.magnetHash, from: client)

			try await confirmation { confirmation in
				for try await hash in client.request(.add(magnetURL: url)).values {
					#expect(hash == TestConfig.magnetHash)
					confirmation.confirm()
				}
			}
		}

		@Test
		func test_addURL() async throws {
			let url = URL(string: TestConfig.webURL)!

			try await ensureTorrentRemoved(hash: TestConfig.webURLHash, from: client)
			for try await _ in client.request(.add(url: url)).values {}
		}

		@Test
		func test_addFileURLAsync() async throws {
			let url = urlForResource(named: TestConfig.torrent2)

			try await ensureTorrentRemoved(hash: TestConfig.torrent2Hash, from: client)

			try await confirmation { confirmation in
				for try await hash in client.request(.addAsync(fileURL: url)).values {
					#expect(hash == TestConfig.torrent2Hash)
					confirmation.confirm()
				}
			}
		}

		@Test
		func test_prefetchMetadata() async throws {
			let url = URL(string: TestConfig.magnetURL)!

			try await ensureTorrentRemoved(hash: TestConfig.magnetHash, from: client)

			try await confirmation { confirmation in
				for try await metadata in client.request(.prefetchMetadata(magnetURL: url)).values {
					#expect(metadata.torrentID == TestConfig.magnetHash)
					confirmation.confirm()
				}
			}
		}

		@Test
		func test_removeTorrent() async throws {
			let url = urlForResource(named: TestConfig.torrent1)
			try await ensureTorrentAdded(fileURL: url, to: client)

			try await confirmation { confirmation in
				for try await removed in client.request(.remove(hash: TestConfig.torrent1Hash, removeData: false)).values {
					#expect(removed)
					confirmation.confirm()
				}
			}
		}

		@Test
		func test_setTrackers() async throws {
			let url = urlForResource(named: TestConfig.torrent1)
			try await ensureTorrentAdded(fileURL: url, to: client)

			let trackers = [Tracker(url: "http://example.com/announce", tier: 0)]
			for try await _ in client.request(.setTrackers(hash: TestConfig.torrent1Hash, trackers: trackers)).values {}

			for try await _ in client.request(
				.setTrackers(hash: TestConfig.torrent1Hash, trackers: TestConfig.torrent1Trackers)
			).values {}
		}

		@Test
		func test_magnetURI() async throws {
			let url = urlForResource(named: TestConfig.torrent1)
			try await ensureTorrentAdded(fileURL: url, to: client)

			try await confirmation { confirmation in
				for try await uri in client.request(.magnetURI(hash: TestConfig.torrent1Hash)).values {
					#expect(uri.hasPrefix("magnet:"))
					confirmation.confirm()
				}
			}
		}

		@Test
		func test_renameFolder() async throws {
			let url = urlForResource(named: TestConfig.torrent1)
			try await ensureTorrentAdded(fileURL: url, to: client)

			for try await _ in client.request(
				.renameFolder(hash: TestConfig.torrent1Hash, folder: "does-not-exist/", newFolder: "renamed/")
			).values {}
		}

		@Test
		func test_reannounce() async throws {
			let url = urlForResource(named: TestConfig.torrent1)

			try await ensureTorrentAdded(fileURL: url, to: client)
			for try await _ in client.request(.reannounce(hashes: [TestConfig.torrent1Hash])).values {}
		}

		@Test
		func test_recheck() async throws {
			let url = urlForResource(named: TestConfig.torrent1)

			try await ensureTorrentAdded(fileURL: url, to: client)
			for try await _ in client.request(.recheck(hashes: [TestConfig.torrent1Hash])).values {}
		}

		@Test
		func test_move() async throws {
			let url = urlForResource(named: TestConfig.torrent1)
			try await ensureTorrentAdded(fileURL: url, to: client)
			for try await _ in client.request(.move(hashes: [TestConfig.torrent1Hash], path: "/tmp")).values {}
		}

		@Test
		func test_removeTorrents_error() async throws {
			for try await errors in client.request(.remove(hashes: ["a"], removeData: false)).values {
				#expect(errors.count == 1)
				#expect(errors.first?.hash == "a")
			}
		}

		@Test
		func test_pause() async throws {
			let url = urlForResource(named: TestConfig.torrent1)
			try await ensureTorrentAdded(fileURL: url, to: client)
			for try await _ in client.request(.pause(hashes: [TestConfig.torrent1Hash])).values {}
		}

		@Test
		func test_queueTop() async throws {
			let url = urlForResource(named: TestConfig.torrent1)
			try await ensureTorrentAdded(fileURL: url, to: client)
			for try await _ in client.request(.queueTop(hashes: [TestConfig.torrent1Hash])).values {}
		}

		@Test
		func test_queueUp() async throws {
			let url = urlForResource(named: TestConfig.torrent1)
			try await ensureTorrentAdded(fileURL: url, to: client)
			for try await _ in client.request(.queueUp(hashes: [TestConfig.torrent1Hash])).values {}
		}

		@Test
		func test_queueDown() async throws {
			let url = urlForResource(named: TestConfig.torrent1)
			try await ensureTorrentAdded(fileURL: url, to: client)
			for try await _ in client.request(.queueDown(hashes: [TestConfig.torrent1Hash])).values {}
		}

		@Test
		func test_queueBottom() async throws {
			let url = urlForResource(named: TestConfig.torrent1)
			try await ensureTorrentAdded(fileURL: url, to: client)
			for try await _ in client.request(.queueBottom(hashes: [TestConfig.torrent1Hash])).values {}
		}

		@Test
		func test_resume() async throws {
			let url = urlForResource(named: TestConfig.torrent1)
			try await ensureTorrentAdded(fileURL: url, to: client)
			for try await _ in client.request(.resume(hashes: [TestConfig.torrent1Hash])).values {}
		}

		@Test
		func test_pauseSession_resumeSession_isSessionPaused() async throws {
			for try await _ in client.request(.pauseSession).values {}
			for try await isPaused in client.request(.isSessionPaused).values {
				#expect(isPaused == true)
			}

			for try await _ in client.request(.resumeSession).values {}
			for try await isPaused in client.request(.isSessionPaused).values {
				#expect(isPaused == false)
			}
		}

		@Test
		func test_sessionStatus() async throws {
			for try await status in client.request(.sessionStatus(keys: ["num_peers", "dht_nodes"])).values {
				#expect(status["num_peers"] != nil)
				#expect(status["dht_nodes"] != nil)
			}
		}

		@Test
		func test_availablePlugins() async throws {
			for try await plugins in client.request(.availablePlugins).values {
				#expect(plugins.contains("Label"))
			}
		}

		@Test
		func test_enabledPlugins() async throws {
			try #require(try await ensurePluginEnabled(.label, from: client), "Label plugin could not be enabled")
			for try await plugins in client.request(.enabledPlugins).values {
				#expect(plugins.contains("Label"))
			}
		}

		@Test
		func test_rescanPlugins() async throws {
			for try await _ in client.request(.rescanPlugins).values {}
		}
	#endif

	@Test
	func test_addFileURL_concurrency() async throws {
		let url = urlForResource(named: TestConfig.torrent2)
		try await ensureTorrentRemoved(hash: TestConfig.torrent2Hash, from: client)
		let hash = try await client.request(.add(fileURL: url))
		#expect(hash == TestConfig.torrent2Hash)
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
	func test_addMagnetURL_concurrency() async throws {
		let url = URL(string: TestConfig.magnetURL)!
		try await ensureTorrentRemoved(hash: TestConfig.magnetHash, from: client)

		let hash = try await client.request(.add(magnetURL: url))
		#expect(hash == TestConfig.magnetHash)
	}

	@Test
	func test_addURL_concurrency() async throws {
		let url = URL(string: TestConfig.webURL)!
		try await ensureTorrentRemoved(hash: TestConfig.webURLHash, from: client)
		try await client.request(.add(url: url))
	}

	@Test
	func test_addFileURLAsync_concurrency() async throws {
		let url = urlForResource(named: TestConfig.torrent2)
		try await ensureTorrentRemoved(hash: TestConfig.torrent2Hash, from: client)
		let hash = try await client.request(.addAsync(fileURL: url))
		#expect(hash == TestConfig.torrent2Hash)
	}

	@Test
	func test_prefetchMetadata_concurrency() async throws {
		let url = URL(string: TestConfig.magnetURL)!
		try await ensureTorrentRemoved(hash: TestConfig.magnetHash, from: client)

		let metadata = try await client.request(.prefetchMetadata(magnetURL: url))
		#expect(metadata.torrentID == TestConfig.magnetHash)
	}

	@Test
	func test_removeTorrent_concurrency() async throws {
		let url = urlForResource(named: TestConfig.torrent1)
		try await ensureTorrentAdded(fileURL: url, to: client)

		let removed = try await client.request(.remove(hash: TestConfig.torrent1Hash, removeData: false))
		#expect(removed)
	}

	@Test
	func test_setTrackers_concurrency() async throws {
		let url = urlForResource(named: TestConfig.torrent1)
		try await ensureTorrentAdded(fileURL: url, to: client)

		let trackers = [Tracker(url: "http://example.com/announce", tier: 0)]
		try await client.request(.setTrackers(hash: TestConfig.torrent1Hash, trackers: trackers))

		try await client.request(.setTrackers(hash: TestConfig.torrent1Hash, trackers: TestConfig.torrent1Trackers))
	}

	@Test
	func test_magnetURI_concurrency() async throws {
		let url = urlForResource(named: TestConfig.torrent1)
		try await ensureTorrentAdded(fileURL: url, to: client)

		let uri = try await client.request(.magnetURI(hash: TestConfig.torrent1Hash))
		#expect(uri.hasPrefix("magnet:"))
	}

	@Test
	func test_renameFolder_concurrency() async throws {
		let url = urlForResource(named: TestConfig.torrent1)
		try await ensureTorrentAdded(fileURL: url, to: client)

		try await client.request(
			.renameFolder(hash: TestConfig.torrent1Hash, folder: "does-not-exist/", newFolder: "renamed/")
		)
	}

	@Test
	func test_reannounce_concurrency() async throws {
		let url = urlForResource(named: TestConfig.torrent1)
		try await ensureTorrentAdded(fileURL: url, to: client)
		try await client.request(.reannounce(hashes: [TestConfig.torrent1Hash]))
	}

	@Test
	func test_recheck_concurrency() async throws {
		let url = urlForResource(named: TestConfig.torrent1)
		try await ensureTorrentAdded(fileURL: url, to: client)
		try await client.request(.recheck(hashes: [TestConfig.torrent1Hash]))
	}

	@Test
	func test_move_concurrency() async throws {
		let url = urlForResource(named: TestConfig.torrent1)
		try await ensureTorrentAdded(fileURL: url, to: client)
		try await client.request(.move(hashes: [TestConfig.torrent1Hash], path: "/tmp"))
	}

	@Test
	func test_removeTorrents_error_concurrency() async throws {
		let errors = try await client.request(.remove(hashes: ["a"], removeData: false))
		#expect(errors.count == 1)
		#expect(errors.first?.hash == "a")
	}

	@Test
	func test_pause_concurrency() async throws {
		let url = urlForResource(named: TestConfig.torrent1)
		try await ensureTorrentAdded(fileURL: url, to: client)
		try await client.request(.pause(hashes: [TestConfig.torrent1Hash]))
	}

	@Test
	func test_queueTop_concurrency() async throws {
		let url = urlForResource(named: TestConfig.torrent1)
		try await ensureTorrentAdded(fileURL: url, to: client)
		try await client.request(.queueTop(hashes: [TestConfig.torrent1Hash]))
	}

	@Test
	func test_queueUp_concurrency() async throws {
		let url = urlForResource(named: TestConfig.torrent1)
		try await ensureTorrentAdded(fileURL: url, to: client)
		try await client.request(.queueUp(hashes: [TestConfig.torrent1Hash]))
	}

	@Test
	func test_queueDown_concurrency() async throws {
		let url = urlForResource(named: TestConfig.torrent1)
		try await ensureTorrentAdded(fileURL: url, to: client)
		try await client.request(.queueDown(hashes: [TestConfig.torrent1Hash]))
	}

	@Test
	func test_queueBottom_concurrency() async throws {
		let url = urlForResource(named: TestConfig.torrent1)
		try await ensureTorrentAdded(fileURL: url, to: client)
		try await client.request(.queueBottom(hashes: [TestConfig.torrent1Hash]))
	}

	@Test
	func test_resume_concurrency() async throws {
		let url = urlForResource(named: TestConfig.torrent1)
		try await ensureTorrentAdded(fileURL: url, to: client)
		try await client.request(.resume(hashes: [TestConfig.torrent1Hash]))
	}

	@Test
	func test_torrentStatus_concurrency() async throws {
		let url = urlForResource(named: TestConfig.torrent1)
		try await ensureTorrentAdded(fileURL: url, to: client)

		let torrent = try await client.request(
			.torrentStatus(hash: TestConfig.torrent1Hash, keys: Torrent.PropertyKeys.allCases)
		)

		#expect(torrent.hash == TestConfig.torrent1Hash)
		#expect(torrent.activeTime != nil)
		#expect(torrent.autoManaged != nil)
		#expect(torrent.completedTime != nil)
		#expect(torrent.comment != nil)
		#expect(torrent.creator != nil)
		#expect(torrent.distributedCopies != nil)
		#expect(torrent.filePriorities != nil)
		#expect(torrent.finishedTime != nil)
		#expect(torrent.isFinished != nil)
		#expect(torrent.isPrivate != nil)
		#expect(torrent.maxDownloadSpeed != nil)
		#expect(torrent.maxUploadSpeed != nil)
		#expect(torrent.moveCompletedPath != nil)
		#expect(torrent.name != nil)
		#expect(torrent.numFiles != nil)
		#expect(torrent.queue != nil)
		#expect(torrent.ratio != nil)
		#expect(torrent.state != nil)
		#expect(torrent.tracker != nil)
		#expect(torrent.trackerHost != nil)
		#expect(torrent.trackerStatus != nil)
		#expect(torrent.trackers == TestConfig.torrent1Trackers)
	}

	@Test
	func test_torrentsStatus_concurrency() async throws {
		let url = urlForResource(named: TestConfig.torrent1)
		try await ensureTorrentAdded(fileURL: url, to: client)

		let torrents = try await client.request(.torrentsStatus(keys: Torrent.PropertyKeys.allCases))

		let torrent = torrents.first(where: { $0.hash == TestConfig.torrent1Hash })
		#expect(torrent?.name != nil)
		#expect(torrent?.state != nil)
		#expect(torrent?.ratio != nil)
		#expect(torrent?.isFinished != nil)
		#expect(torrent?.queue != nil)
	}

	@Test
	func test_filterTree_concurrency() async throws {
		let url = urlForResource(named: TestConfig.torrent1)
		try await ensureTorrentAdded(fileURL: url, to: client)

		let filterTree = try await client.request(.filterTree())
		#expect(filterTree["state"] != nil)
	}

	@Test
	func test_sessionState_concurrency() async throws {
		let url = urlForResource(named: TestConfig.torrent1)
		try await ensureTorrentAdded(fileURL: url, to: client)

		let sessionState = try await client.request(.sessionState)
		#expect(sessionState.contains(TestConfig.torrent1Hash))
	}

	@Test
	func test_pauseSession_resumeSession_isSessionPaused_concurrency() async throws {
		try await client.request(.pauseSession)
		let isPaused = try await client.request(.isSessionPaused)
		#expect(isPaused == true)

		try await client.request(.resumeSession)
		let isResumed = try await client.request(.isSessionPaused)
		#expect(isResumed == false)
	}

	@Test
	func test_sessionStatus_concurrency() async throws {
		let status = try await client.request(.sessionStatus(keys: ["num_peers", "dht_nodes"]))
		#expect(status["num_peers"] != nil)
		#expect(status["dht_nodes"] != nil)
	}

	@Test
	func test_availablePlugins_concurrency() async throws {
		let plugins = try await client.request(.availablePlugins)
		#expect(plugins.contains("Label"))
	}

	@Test
	func test_enabledPlugins_concurrency() async throws {
		try #require(try await ensurePluginEnabled(.label, from: client), "Label plugin could not be enabled")
		let plugins = try await client.request(.enabledPlugins)
		#expect(plugins.contains("Label"))
	}

	@Test
	func test_rescanPlugins_concurrency() async throws {
		try await client.request(.rescanPlugins)
	}
}
