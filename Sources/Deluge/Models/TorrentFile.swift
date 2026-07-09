/// A Deluge torrent file.
public struct TorrentFile: Equatable, Decodable, Sendable {
	/// The index of the file.
	public let index: Int
	/// The name of the file.
	public let name: String
	/// The path of the file.
	public let path: String
	/// The size of the file in bytes.
	public let size: Int64
	/// The download progress of the file as a percentage. This is a value between 0 and 1.
	public let progress: Float
	/// The download priority of the file.
	public let priority: Priority

	/// Initializes a torrent file.
	public init(index: Int, name: String, path: String, size: Int64, progress: Float, priority: Priority) {
		self.index = index
		self.name = name
		self.path = path
		self.size = size
		self.progress = progress
		self.priority = priority
	}
}
