/// An entry in a `core.get_filter_tree` result, representing a value for a filterable field and the number of
/// torrents that match it.
public struct FilterTreeEntry: Equatable, Decodable, Sendable {
	/// The filter value, e.g. a state name, tracker host, label, or owner.
	public var value: String
	/// The number of torrents matching this value.
	public var count: Int

	public init(from decoder: any Decoder) throws {
		var container = try decoder.unkeyedContainer()
		value = try container.decode(String.self)
		count = try container.decode(Int.self)
	}

	/// Initializes a filter tree entry.
	public init(value: String, count: Int) {
		self.value = value
		self.count = count
	}
}
