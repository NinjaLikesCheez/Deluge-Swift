import Foundation

/// A Deluge host
public struct Host: Equatable, Decodable, Sendable {
	// swiftlint:disable:next type_name
	public typealias ID = String

	/// The ID of the host.
	public let id: ID
	/// The URL of the host.
	public let hostURL: URL
	/// The port number of the host.
	public let port: Int
	/// The name of the host.
	public let name: String

	public static func == (lhs: Host, rhs: Host) -> Bool {
		lhs.id == rhs.id
	}

	public init(from decoder: any Decoder) throws {
		let container = try decoder.singleValueContainer()
		let details = try container.decode([HostDetail].self)

		guard details.count == 4 else {
			throw DecodingError.dataCorruptedError(
				in: container,
				debugDescription: "Expected 4 elements, got \(details.count)"
			)
		}

		guard case let .string(id) = details[0] else {
			throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid ID: \(details[0])")
		}

		guard case let .string(urlString) = details[1], let url = URL(string: urlString) else {
			throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid URL: \(details[1])")
		}

		guard case let .int(port) = details[2] else {
			throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid port: \(details[2])")
		}

		guard case let .string(name) = details[3] else {
			throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid name: \(details[3])")
		}

		self.id = id
		hostURL = url
		self.port = port
		self.name = name
	}
}

private enum HostDetail: Decodable, Sendable {
	case int(Int)
	case string(String)

	init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()
		if let integer = try? container.decode(Int.self) {
			self = .int(integer)
			return
		}
		if let string = try? container.decode(String.self) {
			self = .string(string)
			return
		}

		throw DecodingError.typeMismatch(
			HostDetail.self,
			DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for HostDetail")
		)
	}
}
