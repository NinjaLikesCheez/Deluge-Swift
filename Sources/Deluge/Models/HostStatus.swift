/// The connection status of a Deluge host.
public struct HostStatus: Equatable, Decodable, Sendable {
	/// The ID of the host.
	public let id: Host.ID
	/// The connection state, e.g. `"Connected"`, `"Online"`, or `"Offline"`.
	public let state: String
	/// The daemon version, if the host is online or connected. Empty if offline.
	public let version: String

	public init(from decoder: any Decoder) throws {
		var container = try decoder.unkeyedContainer()

		guard container.count == 3 else {
			throw DecodingError.dataCorruptedError(
				in: container,
				debugDescription: "Expected 3 elements, got \(container.count.map(String.init) ?? "unknown")"
			)
		}

		id = try container.decode(Host.ID.self)
		state = try container.decode(String.self)
		version = try container.decode(String.self)
	}
}
