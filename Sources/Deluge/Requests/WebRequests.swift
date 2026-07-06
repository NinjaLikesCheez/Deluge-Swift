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
}
