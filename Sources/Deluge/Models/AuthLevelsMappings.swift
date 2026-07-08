/// The auth level name/value mappings returned by `core.get_auth_levels_mappings`.
public struct AuthLevelsMappings: Decodable, Equatable, Sendable {
	/// Maps an auth level's name to its underlying integer value.
	public let nameToValue: [String: Int]
	/// Maps an auth level's underlying integer value to its name.
	public let valueToName: [Int: String]

	public init(from decoder: any Decoder) throws {
		var container = try decoder.unkeyedContainer()
		nameToValue = try container.decode([String: Int].self)

		let stringKeyedValueToName = try container.decode([String: String].self)
		valueToName = Dictionary(
			uniqueKeysWithValues: stringKeyedValueToName.map { (Int($0.key) ?? 0, $0.value) }
		)
	}
}
