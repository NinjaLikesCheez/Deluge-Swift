/// The result of adding a host via `web.add_host`.
public enum AddHostResult: Equatable, Sendable {
	/// The host was added successfully, with the given ID.
	case success(Host.ID)
	/// The host could not be added, with the given error message.
	case failure(String)
}

extension AddHostResult: Decodable {
	public init(from decoder: any Decoder) throws {
		var container = try decoder.unkeyedContainer()

		guard container.count == 2 else {
			throw DecodingError.dataCorruptedError(
				in: container,
				debugDescription: "Expected 2 elements, got \(container.count.map(String.init) ?? "unknown")"
			)
		}

		let succeeded = try container.decode(Bool.self)
		let message = try container.decode(String.self)

		self = succeeded ? .success(message) : .failure(message)
	}
}
