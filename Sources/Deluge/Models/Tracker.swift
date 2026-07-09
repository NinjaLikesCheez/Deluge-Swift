/// A Deluge torrent tracker.
public struct Tracker: Equatable, Decodable, Sendable {
	/// The tracker URL.
	public let url: String
	/// The tier the tracker belongs to. Trackers in lower tiers are tried first.
	public let tier: Int

	enum CodingKeys: String, CodingKey {
		case url
		case tier
	}

	/// Initializes a tracker.
	public init(url: String, tier: Int = 0) {
		self.url = url
		self.tier = tier
	}

	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		url = try container.decode(String.self, forKey: .url)
		tier = try container.decodeIfPresent(Int.self, forKey: .tier) ?? 0
	}
}

extension Tracker {
	/// Converts this tracker into the dictionary format expected by `core.set_torrent_trackers`.
	var rpcDictionary: [String: Any] {
		[
			CodingKeys.url.stringValue: url,
			CodingKeys.tier.stringValue: tier,
		]
	}
}
