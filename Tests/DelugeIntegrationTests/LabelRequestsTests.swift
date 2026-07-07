import Deluge
import Testing

#if canImport(Combine)
	import Combine
#endif

@Suite("Label Requests", .serialized)
struct LabelRequestsTests {
	#if canImport(Combine)
		@Test()
		func test_setLabel() async throws {
			try #require(try await ensurePluginEnabled(.label, from: client), "Label plugin could not be enabled")
			let url = urlForResource(named: TestConfig.torrent1)
			try await ensureTorrentAdded(fileURL: url, to: client)
			for try await _ in client.request(.setLabel(hash: TestConfig.torrent1Hash, label: "")).values {}
		}
	#endif

	@Test()
	func test_setLabel_concurrency() async throws {
		try #require(try await ensurePluginEnabled(.label, from: client), "Label plugin could not be enabled")
		let url = urlForResource(named: TestConfig.torrent1)
		try await ensureTorrentAdded(fileURL: url, to: client)
		try await client.request(.setLabel(hash: TestConfig.torrent1Hash, label: ""))
	}

	@Test()
	func test_addLabel_getLabels_removeLabel_concurrency() async throws {
		try #require(try await ensurePluginEnabled(.label, from: client), "Label plugin could not be enabled")
		try await ensureLabelRemoved("test-label", from: client)

		try await client.request(.addLabel("test-label"))
		let labels = try await client.request(.labels)
		#expect(labels.contains("test-label"))

		try await client.request(.removeLabel("test-label"))
		let labelsAfterRemoval = try await client.request(.labels)
		#expect(!labelsAfterRemoval.contains("test-label"))
	}

	@Test()
	func test_labelOptions_setLabelOptions_concurrency() async throws {
		try #require(try await ensurePluginEnabled(.label, from: client), "Label plugin could not be enabled")
		try await ensureLabelRemoved("test-options-label", from: client)
		try await client.request(.addLabel("test-options-label"))

		var options = try await client.request(.labelOptions("test-options-label"))
		#expect(options.applyMax == false)

		options.applyMax = true
		options.maxDownloadSpeed = 100
		try await client.request(.setLabelOptions("test-options-label", options: options))

		let updatedOptions = try await client.request(.labelOptions("test-options-label"))
		#expect(updatedOptions.applyMax == true)
		#expect(updatedOptions.maxDownloadSpeed == 100)

		try await client.request(.removeLabel("test-options-label"))
	}

	@Test()
	func test_labelConfig_concurrency() async throws {
		try #require(try await ensurePluginEnabled(.label, from: client), "Label plugin could not be enabled")
		_ = try await client.request(.labelConfig)
	}

	// Deluge's Label plugin has a server-side bug (`options.items` instead of `options.items()` in
	// `deluge_label/core.py`) that makes `label.set_config` raise for any non-empty dict, i.e. always - since we
	// always send `auto_add_trackers`. This is confirmed against a real `linuxserver/deluge` server, so it's an
	// upstream bug rather than something fixable here. Assert the request surfaces that server error rather than
	// silently succeeding.
	@Test()
	func test_setLabelConfig_concurrency() async throws {
		try #require(try await ensurePluginEnabled(.label, from: client), "Label plugin could not be enabled")
		await #expect(throws: Deluge.Error.self) {
			try await client.request(.setLabelConfig(LabelConfig(autoAddTrackers: [])))
		}
	}
}
