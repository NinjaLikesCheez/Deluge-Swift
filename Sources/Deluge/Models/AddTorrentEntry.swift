/// A single torrent to add via `web.add_torrents`, either from a local file path (as returned by
/// `web.download_torrent_from_url`) or a magnet URI, along with its per-torrent options.
public struct AddTorrentEntry {
	/// The path to a local `.torrent` file, or a magnet URI.
	public var path: String
	/// The options to add the torrent with.
	public var options: [TorrentOption]

	/// Initializes an entry for `web.add_torrents`.
	///
	/// - Parameters:
	///   - path: The path to a local `.torrent` file, or a magnet URI.
	///   - options: The options to add the torrent with.
	public init(path: String, options: [TorrentOption] = []) {
		self.path = path
		self.options = options
	}
}

extension AddTorrentEntry {
	var rpcDictionary: [String: Any] {
		[
			"path": path,
			"options": options.reduce(into: [String: Any]()) { $0[$1.key] = $1.value },
		]
	}
}
