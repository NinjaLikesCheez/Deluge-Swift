import Foundation

public extension Request {
    /// Requests the information required to update the web interface.
    ///
    /// RPC Method: `web.update_ui`
    ///
    /// Result: A tuple containing the list of torrents and labels.
    ///
    /// - Parameter properties: The torrent properties to include.
    static func updateUI(properties: [Torrent.PropertyKeys]) -> Request<(torrents: [Torrent], labels: [Label])> {
        .init(method: "web.update_ui", args: [properties.map(\.rawValue), []], transform: parseUpdateUIResponse)
    }

    /// Requests the list of items for a torrent.
    ///
    /// RPC Method: `web.get_torrent_files`
    ///
    /// Result: The list items for the torrent.
    ///
    /// - Parameter hash: The hash of the torrent whose items should be requested.
    static func torrentItems(hash: String) -> Request<[TorrentItem]> {
        .init(method: "web.get_torrent_files", args: [hash], transform: parseTorrentFilesResponse)
    }

    /// Requests the connection status of the Deluge daemon.
    ///
    /// RPC Method: `web.connected`
    ///
    /// Result: A boolean indicating whether the Deluge daemon is currently connected.
    static var connected: Request<Bool> {
        .init(method: "web.connected", args: []) { results in
            if let connected = results["result"] as? Bool {
                return .success(connected)
            }

            return .failure(.unexpectedResponse)
        }
    }

    /// Requests the list of hosts.
    ///
    /// RPC Method: `web.get_hosts`
    ///
    /// Result: The list of hosts.
    static var hosts: Request<[Host]> {
        .init(method: "web.get_hosts", args: [], transform: parseHosts)
    }

    /// Connects to a given host.
    ///
    /// RPC Method: `web.connect`
    ///
    /// - Parameter hostID: The ID of the host to connect to.
    static func connect(to hostID: Host.ID) -> Request<Void> {
        .init(method: "web.connect", args: [hostID])
    }
}

private extension Request {
    /// Parses the hosts out of a `web.get_hosts` response
    /// - Parameter response: The response dictionary.
    /// - Returns: A `Result` containing either the list of hosts, or a `DelugeError` if the response
    /// dictionary could not be parsed
    static func parseHosts(from response: [String: Any]) -> Result<[Host], DelugeError> {
        guard let result = response["result"] as? [[Any]] else { return .failure(.unexpectedResponse) }

        return .success(result.compactMap { hostElements -> Host? in
            guard hostElements.count == 4 else { return nil }

            guard
                let id = hostElements[0] as? String,
                let address = hostElements[1] as? String,
                let port = hostElements[2] as? Int,
                let name = hostElements[3] as? String
            else { return nil }

            guard let url = URL(string: address) else { return nil }

            return Host(id: id, hostURL: url, port: port, name: name)
        })
    }

    /// Parses the labels out of a `web.update_ui` response.
    /// - Parameter response: The response dictionary.
    /// - Returns: The list of labels or an empty array if the response could not be parsed.
    static func parseLabels(from response: [String: Any]) -> [Label] {
        guard let filters = response["filters"] as? [String: Any],
              let labels = filters["label"] as? [[AnyObject]]
        else {
            return []
        }

        return labels.compactMap { pair in
            guard pair.count == 2, let name = pair[0] as? String, name != "All", let count = pair[1] as? Int else {
                return nil
            }

            return Label(name: name, count: count)
        }
    }

    /// Parses the torrents and labels out of a `web.update_ui` response.
    /// - Parameter response: The response dictionary.
    /// - Returns: A `Result` containing either the list of torrents and labels, or an `Error` if the response
    /// dictionary could not be parsed.
    static func parseUpdateUIResponse(
        _ response: [String: Any]
    ) -> Result<(torrents: [Torrent], labels: [Label]), DelugeError> {
        guard let results = response["result"] as? [String: Any],
              let torrents = results["torrents"] as? [String: [String: Any]]
        else {
            return .failure(.unexpectedResponse)
        }

        let labels = Self.parseLabels(from: results)
        return .success((torrents.compactMap { Torrent(hash: $0.key, dictionary: $0.value) }, labels))
    }

    /// Parses the items out of a `web.get_torrent_files` response.
    /// - Parameter response: The response dictionary.
    /// - Returns: A `Result` containing either the list of items or an `Error` if the response dictionary could
    /// not be parsed.
    private static func parseTorrentFilesResponse(_ response: [String: Any]) -> Result<[TorrentItem], DelugeError> {
        guard let results = response["result"] as? [String: Any],
              let contents = results["contents"] as? [String: [String: Any]]
        else {
            return .failure(.unexpectedResponse)
        }

        func parseDirectory(_ contents: [String: [String: Any]]) -> [TorrentItem] {
            var items = [TorrentItem]()
            for (name, node) in contents {
                guard let type = node["type"] as? String else { continue }
                switch type {
                case "dir":
                    guard let child = node["contents"] as? [String: [String: Any]] else { break }
                    items.append(.directory(name: name, items: parseDirectory(child)))
                case "file":
                    guard let file = TorrentFile(name: name, dictionary: node) else { break }
                    items.append(.file(file))
                default:
                    break
                }
            }
            return items
        }

        return .success(parseDirectory(contents))
    }
}
