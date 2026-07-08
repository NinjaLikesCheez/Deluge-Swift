import APIClient
import Foundation

public extension DelugeRequest {
	/// Adds a torrent using a URL to a local torrent file.
	///
	/// RPC Method: `core.add_torrent_file`
	///
	/// Result: The added torrent's hash.
	///
	/// - Parameter fileURL: The URL of the local torrent file to add.
	static func add(fileURL: URL) -> DelugeRequest<String> {
		let fileName = fileURL.lastPathComponent
		let data = FileManager.default.contents(atPath: fileURL.path)?.base64EncodedString() ?? ""
		return .init(
			method: "core.add_torrent_file",
			args: [fileName, data, [String: Any]()]
		)
	}

	/// Adds multiple torrents using multiple URLs to local torrent files.
	///
	/// RPC Method: `core.add_torrent_files`
	///
	/// - Parameter fileURLs: The URLs of the local torrent files to add.
	static func add(fileURLs: [URL]) -> DelugeRequest<EmptyResponse> {
		let files = fileURLs.map { url -> [Any] in
			let fileName = url.lastPathComponent
			let data = FileManager.default.contents(atPath: url.path)?.base64EncodedString() ?? ""
			return [fileName, data, [String: Any]()]
		}
		return .init(method: "core.add_torrent_files", args: [files])
	}

	/// Adds a torrent using a magnet URL.
	///
	/// RPC Method: `core.add_torrent_magnet`
	///
	/// Result: The added torrent's hash.
	///
	/// - Parameter url: The magnet URL to add.
	static func add(magnetURL: URL) -> DelugeRequest<String> {
		.init(
			method: "core.add_torrent_magnet",
			args: [magnetURL.absoluteString, [String: Any]()]
		)
	}

	/// Adds a torrent using a web URL to a torrent file.
	///
	/// RPC Method: `core.add_torrent_url`
	///
	/// - Parameter url: The URL of the torrent file to add.
	static func add(url: URL) -> DelugeRequest<EmptyResponse> {
		.init(method: "core.add_torrent_url", args: [url.absoluteString, [String: Any]()])
	}

	/// Forces a reannounce for torrents with the given hashes.
	///
	/// RPC Method: `core.force_reannounce`
	///
	/// - Parameter hashes: The torrent hashes to force a reannounce on.
	static func reannounce(hashes: [String]) -> DelugeRequest<EmptyResponse> {
		.init(method: "core.force_reannounce", args: [hashes])
	}

	/// Rechecks torrents with the given hashes.
	///
	/// RPC Method: `core.force_recheck`
	///
	/// - Parameter hashes: The torrent hashes to recheck.
	static func recheck(hashes: [String]) -> DelugeRequest<EmptyResponse> {
		.init(method: "core.force_recheck", args: [hashes])
	}

	/// Moves the storage for torrents with the given hashes.
	///
	/// RPC Method: `core.move_storage`
	///
	/// - Parameters:
	///   - hashes: The torrent hashes whose storage should be moved.
	///   - path: The new path where the torrents' data should be stored.
	static func move(hashes: [String], path: String) -> DelugeRequest<EmptyResponse> {
		.init(method: "core.move_storage", args: [hashes, path])
	}

	/// Pauses torrents with the given hashes.
	///
	/// RPC Method: `core.pause_torrents`
	///
	/// - Parameter hashes: The torrent hashes to pause.
	static func pause(hashes: [String]) -> DelugeRequest<EmptyResponse> {
		.init(method: "core.pause_torrents", args: [hashes])
	}

	/// Moves torrents with the given hashes to the top of the queue.
	///
	/// RPC Method: `core.queue_top`
	///
	/// - Parameter hashes: The torrent hashes to move to the top of the queue.
	static func queueTop(hashes: [String]) -> DelugeRequest<EmptyResponse> {
		.init(method: "core.queue_top", args: [hashes])
	}

	/// Moves torrents with the given hashes up one position in the queue.
	///
	/// RPC Method: `core.queue_up`
	///
	/// - Parameter hashes: The torrent hashes to move up in the queue.
	static func queueUp(hashes: [String]) -> DelugeRequest<EmptyResponse> {
		.init(method: "core.queue_up", args: [hashes])
	}

	/// Moves torrents with the given hashes down one position in the queue.
	///
	/// RPC Method: `core.queue_down`
	///
	/// - Parameter hashes: The torrent hashes to move down in the queue.
	static func queueDown(hashes: [String]) -> DelugeRequest<EmptyResponse> {
		.init(method: "core.queue_down", args: [hashes])
	}

	/// Moves torrents with the given hashes to the bottom of the queue.
	///
	/// RPC Method: `core.queue_bottom`
	///
	/// - Parameter hashes: The torrent hashes to move to the bottom of the queue.
	static func queueBottom(hashes: [String]) -> DelugeRequest<EmptyResponse> {
		.init(method: "core.queue_bottom", args: [hashes])
	}

	/// Removes torrents with the given hashes.
	///
	/// RPC Method: `core.remove_torrents`
	///
	/// Result: An array of torrent hashes and error messages, or an empty array if no errors occurred.
	///
	/// - Parameters:
	///   - hashes: The torrent hashes to remove.
	///   - removeData: Whether the torrents' data should be removed.
	static func remove(hashes: [String], removeData: Bool) -> DelugeRequest<[RemoveTorrentError]> {
		.init(
			method: "core.remove_torrents",
			args: [hashes, removeData],
			transform: { data in
				let response = try JSONDecoder().decode(Deluge.Response<[[String]]>.self, from: data)

				var errors = [RemoveTorrentError]()
				for result in response.result {
					assert(result.count.isMultiple(of: 2))

					var index = 0
					while index < result.count {
						errors.append(.init(hash: result[index], error: result[index + 1]))
						index += 2
					}
				}

				return errors
			}
		)
	}

	/// Resumes torrents with the given hashes.
	///
	/// RPC Method: `core.resume_torrents`
	///
	/// - Parameter hashes: The torrent hashes to resume.
	static func resume(hashes: [String]) -> DelugeRequest<EmptyResponse> {
		.init(method: "core.resume_torrents", args: [hashes])
	}

	/// Sets options for torrents with the given hashes.
	///
	/// RPC Method: `core.set_torrent_options`
	///
	/// - Parameters:
	///   - hashes: The torrent hashes to update.
	///   - options: The options to set on the torrents.
	static func setOptions(hashes: [String], options: [TorrentOption]) -> DelugeRequest<EmptyResponse> {
		.init(
			method: "core.set_torrent_options",
			args: [
				hashes,
				options.reduce(into: [String: Any]()) { $0[$1.key] = $1.value },
			])
	}

	/// Enables a plugin.
	///
	/// RPC Method: `core.enable_plugin`
	///
	/// - Parameter plugin: The plugin to enable.
	static func enablePlugin(_ plugin: Plugin) -> DelugeRequest<Bool> {
		.init(method: "core.enable_plugin", args: [plugin.name])
	}

	/// Disables a plugin.
	///
	/// RPC Method: `core.disable_plugin`
	///
	/// - Parameter plugin: The plugin to disable.
	static func disablePlugin(_ plugin: Plugin) -> DelugeRequest<Bool> {
		.init(method: "core.disable_plugin", args: [plugin.name])
	}

	/// Requests the status for a single torrent.
	///
	/// RPC Method: `core.get_torrent_status`
	///
	/// Result: The torrent's status for the requested keys.
	///
	/// - Parameters:
	///   - hash: The hash of the torrent whose status should be requested.
	///   - keys: The status keys to request. An empty array requests all keys.
	static func torrentStatus(hash: String, keys: [Torrent.PropertyKeys]) -> DelugeRequest<Torrent> {
		.init(
			method: "core.get_torrent_status",
			args: [hash, keys.map(\.rawValue)],
			transform: { data in
				let response = try JSONDecoder().decode(Deluge.Response<UnhashedTorrent>.self, from: data)
				return Torrent(hash: hash, torrent: response.result)
			}
		)
	}

	/// Requests the status for torrents matching the given filter.
	///
	/// RPC Method: `core.get_torrents_status`
	///
	/// Result: The matching torrents' statuses for the requested keys.
	///
	/// - Parameters:
	///   - filter: The filter used to select torrents, e.g. `["state": "Seeding"]`. An empty dictionary matches
	///     all torrents.
	///   - keys: The status keys to request. An empty array requests all keys.
	static func torrentsStatus(
		filter: [String: Any] = [:],
		keys: [Torrent.PropertyKeys]
	) -> DelugeRequest<[Torrent]> {
		.init(
			method: "core.get_torrents_status",
			args: [filter, keys.map(\.rawValue)],
			transform: { data in
				let response = try JSONDecoder().decode(Deluge.Response<[String: UnhashedTorrent]>.self, from: data)
				return response.result.map { Torrent(hash: $0.key, torrent: $0.value) }
			}
		)
	}

	/// Requests the filter tree used to build sidebar filters (by state, tracker, label, owner, etc).
	///
	/// RPC Method: `core.get_filter_tree`
	///
	/// Result: A dictionary of filterable fields to the values and torrent counts for each.
	///
	/// - Parameters:
	///   - showZeroHits: Whether values with zero matching torrents should be included.
	///   - hideCategories: The filter fields that should be excluded from the result.
	static func filterTree(
		showZeroHits: Bool = true,
		hideCategories: [String] = []
	) -> DelugeRequest<[String: [FilterTreeEntry]]> {
		.init(method: "core.get_filter_tree", args: [showZeroHits, hideCategories])
	}

	/// Requests the hashes of the torrents currently in the session.
	///
	/// RPC Method: `core.get_session_state`
	///
	/// Result: The list of torrent hashes in the session.
	static var sessionState: DelugeRequest<[String]> {
		.init(method: "core.get_session_state", args: [])
	}
}
