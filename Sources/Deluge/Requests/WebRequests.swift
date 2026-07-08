import APIClient
import Foundation

private struct ConnectedResponse: Decodable {
	let connected: Bool
}

public extension DelugeRequest {
	/// Requests the information required to update the web interface.
	///
	/// RPC Method: `web.update_ui`
	///
	/// Result: A tuple containing the list of torrents and labels.
	///
	/// - Parameter properties: The torrent properties to include.
	static func updateUI(properties: [Torrent.PropertyKeys]) -> DelugeRequest<TorrentsAndLabels> {
		.init(
			method: "web.update_ui",
			args: [properties.map(\.rawValue), []],
			transform: { data in
				// this is seemingly the only API that has a 'connected' property that tells us if we are connected
				// but, when it's false - the other properties are null.
				// So we have to decode a custom response first to check, then decode the result if we're connected
				let response = try JSONDecoder().decode(Deluge.Response<ConnectedResponse>.self, from: data)

				guard response.result.connected else {
					throw Deluge.Error.response(.unconnected)
				}

				return try JSONDecoder().decode(Deluge.Response<TorrentsAndLabels>.self, from: data).result
			}
		)
	}

	/// Requests the list of items for a torrent.
	///
	/// RPC Method: `web.get_torrent_files`
	///
	/// Result: The list items for the torrent.
	///
	/// - Parameter hash: The hash of the torrent whose items should be requested.
	static func torrentItems(hash: String) -> DelugeRequest<[TorrentItem]> {
		.init(method: "web.get_torrent_files", args: [hash]) { data in
			let response = try JSONDecoder().decode(Deluge.Response<TorrentTree>.self, from: data)
			return response.result.toItems()
		}
	}

	/// Requests the connection status of the Deluge daemon.
	///
	/// RPC Method: `web.connected`
	///
	/// Result: A boolean indicating whether the Deluge daemon is currently connected.
	static var connected: DelugeRequest<Bool> {
		.init(method: "web.connected", args: [])
	}

	/// Requests the list of hosts.
	///
	/// RPC Method: `web.get_hosts`
	///
	/// Result: The list of hosts.
	static var hosts: DelugeRequest<[Host]> {
		.init(method: "web.get_hosts", args: [])
	}

	/// Connects to a given host.
	///
	/// RPC Method: `web.connect`
	///
	/// - Parameter hostID: The ID of the host to connect to.
	static func connect(to hostID: Host.ID) -> DelugeRequest<EmptyResponse> {
		.init(method: "web.connect", args: [hostID])
	}

	/// Disconnects from the current host.
	///
	/// RPC Method: `web.disconnect`
	static var disconnect: DelugeRequest<EmptyResponse> {
		.init(method: "web.disconnect", args: [])
	}

	/// All avaliable and enables plugins in the web UI
	///
	/// RPC Method: `web.get_plugins`
	static var plugins: DelugeRequest<Plugins> {
		.init(method: "web.get_plugins", args: [])
	}

	/// Requests the status for a single torrent, filtered to the given properties.
	///
	/// RPC Method: `web.get_torrent_status`
	///
	/// - Parameters:
	///   - hash: The hash of the torrent whose status should be requested.
	///   - properties: The torrent properties to include.
	static func torrentStatus(hash: String, properties: [Torrent.PropertyKeys]) -> DelugeRequest<Torrent> {
		.init(
			method: "web.get_torrent_status",
			args: [hash, properties.map(\.rawValue)],
			transform: { data in
				let response = try JSONDecoder().decode(Deluge.Response<UnhashedTorrent>.self, from: data)
				return Torrent(hash: hash, torrent: response.result)
			}
		)
	}

	/// Downloads a `.torrent` file from a URL to a temporary location on the server, without adding it.
	///
	/// RPC Method: `web.download_torrent_from_url`
	///
	/// Result: The temporary file name of the downloaded `.torrent` file.
	///
	/// - Parameters:
	///   - url: The URL of the torrent file to download.
	///   - cookie: An optional cookie header to send with the download request.
	static func downloadTorrent(fromURL url: URL, cookie: String? = nil) -> DelugeRequest<String> {
		.init(method: "web.download_torrent_from_url", args: [url.absoluteString, cookie as Any])
	}

	/// Parses a not-yet-added `.torrent` file on the server for metadata.
	///
	/// RPC Method: `web.get_torrent_info`
	///
	/// Result: Information about the torrent, or `nil` if the file could not be parsed.
	///
	/// - Parameter filename: The path to the `.torrent` file on the server, e.g. as returned by
	///   ``downloadTorrent(fromURL:cookie:)``.
	static func torrentInfo(filename: String) -> DelugeRequest<TorrentFileInfo?> {
		.init(
			method: "web.get_torrent_info",
			args: [filename],
			transform: { data in
				if let response = try? JSONDecoder().decode(Deluge.Response<TorrentFileInfo>.self, from: data) {
					return response.result
				}
				// The server returns `false` if the file could not be parsed.
				_ = try JSONDecoder().decode(Deluge.Response<Bool>.self, from: data)
				return nil
			}
		)
	}

	/// Parses a magnet URI for metadata.
	///
	/// RPC Method: `web.get_magnet_info`
	///
	/// Result: Information about the magnet URI, or `nil` if the URI could not be parsed.
	///
	/// - Parameter uri: The magnet URI to parse.
	static func magnetInfo(uri: String) -> DelugeRequest<MagnetInfo?> {
		.init(
			method: "web.get_magnet_info",
			args: [uri],
			transform: { data in
				if let response = try? JSONDecoder().decode(Deluge.Response<MagnetInfo>.self, from: data) {
					return response.result
				}
				// The server returns an empty dictionary if the URI could not be parsed.
				return nil
			}
		)
	}

	/// Adds multiple torrents in a single call, each with its own options.
	///
	/// RPC Method: `web.add_torrents`
	///
	/// - Parameter torrents: The torrents to add, either from local file paths or magnet URIs.
	static func addTorrents(_ torrents: [AddTorrentEntry]) -> DelugeRequest<EmptyResponse> {
		.init(method: "web.add_torrents", args: [torrents.map(\.rpcDictionary)])
	}

	/// Requests the current connection status for a specific host.
	///
	/// RPC Method: `web.get_host_status`
	///
	/// - Parameter hostID: The ID of the host whose status should be requested.
	static func hostStatus(hostID: Host.ID) -> DelugeRequest<HostStatus> {
		.init(method: "web.get_host_status", args: [hostID])
	}

	/// Registers a new daemon host.
	///
	/// RPC Method: `web.add_host`
	///
	/// - Parameters:
	///   - host: The IP address or hostname of the daemon.
	///   - port: The port of the daemon.
	///   - username: The username to authenticate with the daemon.
	///   - password: The password to authenticate with the daemon.
	static func addHost(
		host: String,
		port: Int,
		username: String = "",
		password: String = ""
	) -> DelugeRequest<AddHostResult> {
		.init(method: "web.add_host", args: [host, port, username, password])
	}

	/// Edits the details of an existing host.
	///
	/// RPC Method: `web.edit_host`
	///
	/// Result: Whether the host was successfully updated.
	///
	/// - Parameters:
	///   - hostID: The ID of the host to edit.
	///   - host: The new IP address or hostname of the daemon.
	///   - port: The new port of the daemon.
	///   - username: The new username to authenticate with the daemon.
	///   - password: The new password to authenticate with the daemon.
	static func editHost(
		hostID: Host.ID,
		host: String,
		port: Int,
		username: String = "",
		password: String = ""
	) -> DelugeRequest<Bool> {
		.init(method: "web.edit_host", args: [hostID, host, port, username, password])
	}

	/// Removes a host from the host list.
	///
	/// RPC Method: `web.remove_host`
	///
	/// Result: Whether the host was successfully removed.
	///
	/// - Parameter hostID: The ID of the host to remove.
	static func removeHost(hostID: Host.ID) -> DelugeRequest<Bool> {
		.init(method: "web.remove_host", args: [hostID])
	}

	/// Starts a local daemon on the given port.
	///
	/// RPC Method: `web.start_daemon`
	///
	/// - Parameter port: The port the daemon should listen on.
	static func startDaemon(port: Int) -> DelugeRequest<EmptyResponse> {
		.init(method: "web.start_daemon", args: [port])
	}

	/// Stops a running daemon.
	///
	/// RPC Method: `web.stop_daemon`
	///
	/// - Parameter hostID: The ID of the host whose daemon should be stopped.
	static func stopDaemon(hostID: Host.ID) -> DelugeRequest<EmptyResponse> {
		.init(method: "web.stop_daemon", args: [hostID])
	}

	/// Requests the web interface's own configuration. This is distinct from ``core.get_config``.
	///
	/// RPC Method: `web.get_config`
	static var webConfig: DelugeRequest<[String: JSONValue]> {
		.init(method: "web.get_config", args: [])
	}

	/// Sets values in the web interface's own configuration.
	///
	/// RPC Method: `web.set_config`
	///
	/// - Parameter config: The configuration values to update.
	static func setWebConfig(_ config: [String: JSONValue]) -> DelugeRequest<EmptyResponse> {
		.init(method: "web.set_config", args: [config.mapValues(\.rpcValue)])
	}

	/// Requests the details for a plugin.
	///
	/// RPC Method: `web.get_plugin_info`
	///
	/// - Parameter name: The name of the plugin.
	static func pluginInfo(name: String) -> DelugeRequest<[String: JSONValue]> {
		.init(method: "web.get_plugin_info", args: [name])
	}

	/// Requests the resource data files for a plugin.
	///
	/// RPC Method: `web.get_plugin_resources`
	///
	/// - Parameter name: The name of the plugin.
	static func pluginResources(name: String) -> DelugeRequest<[String: JSONValue]> {
		.init(method: "web.get_plugin_resources", args: [name])
	}

	/// Uploads a plugin file to the server.
	///
	/// RPC Method: `web.upload_plugin`
	///
	/// - Parameters:
	///   - filename: The name to save the plugin file as.
	///   - path: The path to the plugin file to upload.
	static func uploadPlugin(filename: String, path: String) -> DelugeRequest<Bool> {
		.init(method: "web.upload_plugin", args: [filename, path])
	}

	/// Registers a listener for a given event on the current session.
	///
	/// RPC Method: `web.register_event_listener`
	///
	/// - Parameter event: The name of the event to listen for.
	static func registerEventListener(event: String) -> DelugeRequest<EmptyResponse> {
		.init(method: "web.register_event_listener", args: [event])
	}

	/// Removes a listener for a given event from the current session.
	///
	/// RPC Method: `web.deregister_event_listener`
	///
	/// - Parameter event: The name of the event to stop listening for.
	static func deregisterEventListener(event: String) -> DelugeRequest<EmptyResponse> {
		.init(method: "web.deregister_event_listener", args: [event])
	}

	/// Requests the pending events for the current session.
	///
	/// RPC Method: `web.get_events`
	static var events: DelugeRequest<[JSONValue]> {
		.init(method: "web.get_events", args: [])
	}

	/// Requests the available translated languages for the web interface.
	///
	/// RPC Method: `webutils.get_languages`
	///
	/// Result: A list of language ID and display name pairs.
	static var languages: DelugeRequest<[[String]]> {
		.init(method: "webutils.get_languages", args: [])
	}
}
