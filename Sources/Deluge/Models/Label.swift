/// A Deluge label.
public struct Label: Equatable, Decodable, Hashable, Sendable {
	/// The label name.
	public let name: String
	/// The number of torrents with this label.
	public let count: Int
}
