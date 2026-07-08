/// The result of creating a new `.torrent` file server-side.
public struct CreateTorrentResult: Decodable, Sendable {
	/// The filename of the created torrent.
	public let filename: String
	/// The base64 encoded, bencoded contents of the created torrent file.
	public let fileContents: String

	public init(from decoder: Decoder) throws {
		var container = try decoder.unkeyedContainer()
		filename = try container.decode(String.self)
		fileContents = try container.decode(String.self)
	}
}

/// The torrent format used when creating a new torrent with `core.create_torrent`.
public enum TorrentFormat: String, Sendable {
	/// BitTorrent v1 format.
	case v1
	/// BitTorrent v2 format.
	case v2
	/// A hybrid format supporting both v1 and v2.
	case hybrid
}
