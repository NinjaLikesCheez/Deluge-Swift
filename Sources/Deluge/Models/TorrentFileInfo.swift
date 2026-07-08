/// Information about a not-yet-added torrent file, as returned by `web.get_torrent_info`.
public struct TorrentFileInfo: Equatable, Decodable, Sendable {
	/// The name of the torrent.
	public let name: String
	/// The info hash of the torrent.
	public let infoHash: String
	/// The files contained in the torrent.
	public let files: [TorrentFileTreeItem]

	enum CodingKeys: String, CodingKey {
		case name
		case infoHash = "info_hash"
		case filesTree = "files_tree"
	}

	public init(from decoder: any Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		name = try container.decode(String.self, forKey: .name)
		infoHash = try container.decode(String.self, forKey: .infoHash)
		files = try container.decode(TorrentFileTree.self, forKey: .filesTree).toItems()
	}
}

/// Information parsed from a magnet URI, as returned by `web.get_magnet_info`.
public struct MagnetInfo: Equatable, Decodable, Sendable {
	/// The name of the torrent.
	public let name: String
	/// The info hash of the torrent.
	public let infoHash: String
	/// The trackers included in the magnet URI, mapped to their tier.
	public let trackers: [String: Int]

	enum CodingKeys: String, CodingKey {
		case name
		case infoHash = "info_hash"
		case trackers
	}

	public init(from decoder: any Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		name = try container.decode(String.self, forKey: .name)
		infoHash = try container.decode(String.self, forKey: .infoHash)
		trackers = try container.decodeIfPresent([String: Int].self, forKey: .trackers) ?? [:]
	}
}
