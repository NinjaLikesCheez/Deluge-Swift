/// Plugin-wide configuration for the Label plugin, as returned by `label.get_config`.
public struct LabelConfig: Equatable, Decodable, Hashable, Sendable {
	/// The tracker URLs used to automatically match and assign labels to new torrents.
	public var autoAddTrackers: [String]

	enum CodingKeys: String, CodingKey {
		case autoAddTrackers = "auto_add_trackers"
	}

	public init(autoAddTrackers: [String] = []) {
		self.autoAddTrackers = autoAddTrackers
	}

	public init(from decoder: any Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		// The server only includes `auto_add_trackers` in the response once it has been explicitly set at least
		// once via `label.set_config`.
		autoAddTrackers = try container.decodeIfPresent([String].self, forKey: .autoAddTrackers) ?? []
	}
}

extension LabelConfig {
	/// Converts this config into the dictionary format expected by `label.set_config`.
	var rpcDictionary: [String: Any] {
		[CodingKeys.autoAddTrackers.stringValue: autoAddTrackers]
	}
}
