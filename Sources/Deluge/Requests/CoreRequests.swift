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

	/// Adds a torrent using a URL to a local torrent file, asynchronously.
	///
	/// RPC Method: `core.add_torrent_file_async`
	///
	/// Result: The added torrent's hash, or `nil` if the torrent was not added.
	///
	/// - Parameters:
	///   - fileURL: The URL of the local torrent file to add.
	///   - saveState: Whether the session state should be saved after adding the torrent.
	static func addAsync(fileURL: URL, saveState: Bool = true) -> DelugeRequest<String?> {
		let fileName = fileURL.lastPathComponent
		let data = FileManager.default.contents(atPath: fileURL.path)?.base64EncodedString() ?? ""
		return .init(
			method: "core.add_torrent_file_async",
			args: [fileName, data, [String: Any](), saveState]
		)
	}

	/// Downloads a magnet URL's metadata without adding it to the session.
	///
	/// Useful for presenting a file-selection UI before adding a torrent to the session.
	///
	/// RPC Method: `core.prefetch_magnet_metadata`
	///
	/// - Parameters:
	///   - magnetURL: The magnet URL to prefetch metadata for.
	///   - timeout: The number of seconds to wait before canceling the request.
	static func prefetchMetadata(magnetURL: URL, timeout: Int = 30) -> DelugeRequest<MagnetMetadata> {
		.init(
			method: "core.prefetch_magnet_metadata",
			args: [magnetURL.absoluteString, timeout],
			transform: { data in
				let response = try JSONDecoder().decode(Deluge.Response<[String]>.self, from: data)
				assert(response.result.count == 2)
				return MagnetMetadata(torrentID: response.result[0], metadata: response.result[1])
			}
		)
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

	/// Removes a single torrent.
	///
	/// RPC Method: `core.remove_torrent`
	///
	/// Result: Whether the torrent was removed successfully.
	///
	/// - Parameters:
	///   - hash: The torrent hash to remove.
	///   - removeData: Whether the torrent's data should be removed.
	static func remove(hash: String, removeData: Bool) -> DelugeRequest<Bool> {
		.init(method: "core.remove_torrent", args: [hash, removeData])
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

	/// Manually adds a peer to a torrent.
	///
	/// RPC Method: `core.connect_peer`
	///
	/// - Parameters:
	///   - hash: The torrent hash to add the peer to.
	///   - ip: The peer's IP address.
	///   - port: The peer's port.
	static func connectPeer(hash: String, ip: String, port: Int) -> DelugeRequest<EmptyResponse> {
		.init(method: "core.connect_peer", args: [hash, ip, port])
	}

	/// Sets the SSL certificate used to connect to SSL peers of a torrent.
	///
	/// RPC Method: `core.set_ssl_torrent_cert`
	///
	/// - Parameters:
	///   - hash: The torrent hash to set the certificate for.
	///   - certificate: The SSL certificate.
	///   - privateKey: The private key for the certificate.
	///   - dhParams: The Diffie-Hellman parameters.
	///   - saveToDisk: Whether the certificate files should be saved to disk.
	static func setSSLCert(
		hash: String,
		certificate: String,
		privateKey: String,
		dhParams: String,
		saveToDisk: Bool = true
	) -> DelugeRequest<EmptyResponse> {
		.init(
			method: "core.set_ssl_torrent_cert",
			args: [hash, certificate, privateKey, dhParams, saveToDisk]
		)
	}

	/// Replaces a torrent's tracker list.
	///
	/// RPC Method: `core.set_torrent_trackers`
	///
	/// - Parameters:
	///   - hash: The torrent hash to update.
	///   - trackers: The new list of trackers for the torrent.
	static func setTrackers(hash: String, trackers: [Tracker]) -> DelugeRequest<EmptyResponse> {
		.init(method: "core.set_torrent_trackers", args: [hash, trackers.map(\.rpcDictionary)])
	}

	/// Requests the magnet URI for a torrent.
	///
	/// RPC Method: `core.get_magnet_uri`
	///
	/// - Parameter hash: The torrent hash to get the magnet URI for.
	static func magnetURI(hash: String) -> DelugeRequest<String> {
		.init(method: "core.get_magnet_uri", args: [hash])
	}

	/// Renames files in a torrent.
	///
	/// RPC Method: `core.rename_files`
	///
	/// - Parameters:
	///   - hash: The torrent hash whose files should be renamed.
	///   - filenames: The list of `(index, filename)` pairs describing the renames to perform.
	static func renameFiles(hash: String, filenames: [(index: Int, filename: String)]) -> DelugeRequest<EmptyResponse> {
		.init(method: "core.rename_files", args: [hash, filenames.map { [$0.index, $0.filename] }])
	}

	/// Renames a folder within a torrent.
	///
	/// RPC Method: `core.rename_folder`
	///
	/// - Parameters:
	///   - hash: The torrent hash containing the folder.
	///   - folder: The folder to rename.
	///   - newFolder: The new folder name.
	static func renameFolder(hash: String, folder: String, newFolder: String) -> DelugeRequest<EmptyResponse> {
		.init(method: "core.rename_folder", args: [hash, folder, newFolder])
	}

	/// Creates a new `.torrent` file server-side.
	///
	/// RPC Method: `core.create_torrent`
	///
	/// Result: The created torrent's filename and base64 encoded, bencoded contents.
	///
	/// - Parameters:
	///   - path: The path, on the server, of the file or directory to create a torrent from.
	///   - tracker: The primary tracker URL.
	///   - pieceLength: The size of each piece in the torrent, in bytes.
	///   - comment: An optional comment to include in the torrent.
	///   - target: An optional path, on the server, to save the created torrent file to.
	///   - webSeeds: An optional list of webseed URLs.
	///   - isPrivate: Whether the torrent should be marked private.
	///   - createdBy: An optional string identifying the torrent's creator.
	///   - trackers: An optional list of additional tracker URLs.
	///   - addToSession: Whether the created torrent should be added to the session.
	///   - format: The torrent format to create.
	static func createTorrent(
		path: String,
		tracker: String,
		pieceLength: Int,
		comment: String? = nil,
		target: String? = nil,
		webSeeds: [String]? = nil,
		isPrivate: Bool = false,
		createdBy: String? = nil,
		trackers: [String]? = nil,
		addToSession: Bool = false,
		format: TorrentFormat = .v1
	) -> DelugeRequest<CreateTorrentResult> {
		.init(
			method: "core.create_torrent",
			args: [
				path,
				tracker,
				pieceLength,
				comment as Any,
				target as Any,
				webSeeds as Any,
				isPrivate,
				createdBy as Any,
				trackers as Any,
				addToSession,
				format.rawValue,
			]
		)
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

	/// Pauses the libtorrent session, pausing all torrents.
	///
	/// RPC Method: `core.pause_session`
	static var pauseSession: DelugeRequest<EmptyResponse> {
		.init(method: "core.pause_session", args: [])
	}

	/// Resumes the libtorrent session, resuming all torrents that aren't individually paused.
	///
	/// RPC Method: `core.resume_session`
	static var resumeSession: DelugeRequest<EmptyResponse> {
		.init(method: "core.resume_session", args: [])
	}

	/// Requests whether the libtorrent session is paused.
	///
	/// RPC Method: `core.is_session_paused`
	static var isSessionPaused: DelugeRequest<Bool> {
		.init(method: "core.is_session_paused", args: [])
	}

	/// Requests values from the libtorrent session status.
	///
	/// RPC Method: `core.get_session_status`
	///
	/// Result: A dictionary mapping each requested key to its value.
	///
	/// - Parameter keys: The libtorrent session status keys to request. Refer to
	///   [session_status](https://www.libtorrent.org/reference-Session_Status.html) in the libtorrent documentation
	///   for valid keys.
	static func sessionStatus(keys: [String]) -> DelugeRequest<[String: Double]> {
		.init(method: "core.get_session_status", args: [keys])
	}

	/// Requests the list of plugins available to the daemon.
	///
	/// RPC Method: `core.get_available_plugins`
	///
	/// Result: The names of the available plugins.
	static var availablePlugins: DelugeRequest<[String]> {
		.init(method: "core.get_available_plugins", args: [])
	}

	/// Requests the list of plugins currently enabled on the daemon.
	///
	/// RPC Method: `core.get_enabled_plugins`
	///
	/// Result: The names of the enabled plugins.
	static var enabledPlugins: DelugeRequest<[String]> {
		.init(method: "core.get_enabled_plugins", args: [])
	}

	/// Uploads a new plugin egg to the daemon.
	///
	/// RPC Method: `core.upload_plugin`
	///
	/// - Parameter fileURL: The URL of the local plugin egg file to upload.
	static func uploadPlugin(fileURL: URL) -> DelugeRequest<EmptyResponse> {
		let fileName = fileURL.lastPathComponent
		let data = FileManager.default.contents(atPath: fileURL.path)?.base64EncodedString() ?? ""
		return .init(method: "core.upload_plugin", args: [fileName, data])
	}

	/// Scans the plugin folders for new plugins.
	///
	/// RPC Method: `core.rescan_plugins`
	static var rescanPlugins: DelugeRequest<EmptyResponse> {
		.init(method: "core.rescan_plugins", args: [])
	}

	/// Requests the list of known user accounts. Requires admin authentication.
	///
	/// RPC Method: `core.get_known_accounts`
	static var knownAccounts: DelugeRequest<[Account]> {
		.init(method: "core.get_known_accounts", args: [])
	}

	/// Requests the mappings between named authentication levels and their underlying integer values.
	///
	/// RPC Method: `core.get_auth_levels_mappings`
	static var authLevelsMappings: DelugeRequest<AuthLevelsMappings> {
		.init(method: "core.get_auth_levels_mappings", args: [])
	}

	/// Creates a new user account. Requires admin authentication.
	///
	/// RPC Method: `core.create_account`
	///
	/// - Parameters:
	///   - username: The username for the new account.
	///   - password: The password for the new account.
	///   - authLevel: The authentication level for the new account.
	static func createAccount(username: String, password: String, authLevel: AuthLevel) -> DelugeRequest<Bool> {
		.init(method: "core.create_account", args: [username, password, authLevel.rawValue])
	}

	/// Updates an existing user account. Requires admin authentication.
	///
	/// RPC Method: `core.update_account`
	///
	/// - Parameters:
	///   - username: The username of the account to update.
	///   - password: The new password for the account.
	///   - authLevel: The new authentication level for the account.
	static func updateAccount(username: String, password: String, authLevel: AuthLevel) -> DelugeRequest<Bool> {
		.init(method: "core.update_account", args: [username, password, authLevel.rawValue])
	}

	/// Removes a user account. Requires admin authentication.
	///
	/// RPC Method: `core.remove_account`
	///
	/// - Parameter username: The username of the account to remove.
	static func removeAccount(username: String) -> DelugeRequest<Bool> {
		.init(method: "core.remove_account", args: [username])
	}
}
