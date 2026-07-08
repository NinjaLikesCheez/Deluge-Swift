/// The result of prefetching a magnet URL's metadata without adding it to the session.
public struct MagnetMetadata: Decodable, Sendable {
	/// The torrent's hash, derived from the magnet URI.
	public let torrentID: String
	/// The base64 encoded, bencoded torrent metadata.
	public let metadata: String
}
