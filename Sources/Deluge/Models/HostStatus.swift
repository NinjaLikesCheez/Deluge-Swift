/// The connection status of a Deluge host, as returned by `web.get_host_status`.
public enum HostStatus: Equatable, Sendable {
	/// The web client is currently connected to this host.
	case connected(id: Host.ID, version: String)
	/// The host's daemon is reachable but the web client isn't connected to it.
	case online(id: Host.ID, version: String)
	/// The host's daemon could not be reached.
	case offline(id: Host.ID)

	/// The ID of the host.
	public var id: Host.ID {
		switch self {
		case let .connected(id, _), let .online(id, _), let .offline(id):
			return id
		}
	}
}

extension HostStatus: Decodable {
	public init(from decoder: any Decoder) throws {
		var container = try decoder.unkeyedContainer()

		guard container.count == 3 else {
			throw DecodingError.dataCorruptedError(
				in: container,
				debugDescription: "Expected 3 elements, got \(container.count.map(String.init) ?? "unknown")"
			)
		}

		let id = try container.decode(Host.ID.self)
		let state = try container.decode(String.self)
		let version = try container.decode(String.self)

		switch state {
		case "Connected":
			self = .connected(id: id, version: version)
		case "Online":
			self = .online(id: id, version: version)
		case "Offline":
			self = .offline(id: id)
		default:
			throw DecodingError.dataCorruptedError(
				in: container,
				debugDescription: "Unknown host status state: \(state)"
			)
		}
	}
}
