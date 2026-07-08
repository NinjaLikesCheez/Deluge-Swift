import Foundation

public extension Deluge {
	/// A dynamically-typed JSON value, used for RPC methods whose result or arguments have a shape that isn't
	/// known ahead of time, such as daemon config values.
	enum Value: Equatable, Hashable, Sendable {
		case string(String)
		case int(Int)
		case double(Double)
		case bool(Bool)
		case array([Value])
		case dictionary([String: Value])
		case null
	}
}

extension Deluge.Value: Decodable {
	public init(from decoder: any Decoder) throws {
		let container = try decoder.singleValueContainer()

		if container.decodeNil() {
			self = .null
		} else if let value = try? container.decode(Bool.self) {
			self = .bool(value)
		} else if let value = try? container.decode(Int.self) {
			self = .int(value)
		} else if let value = try? container.decode(Double.self) {
			self = .double(value)
		} else if let value = try? container.decode(String.self) {
			self = .string(value)
		} else if let value = try? container.decode([Deluge.Value].self) {
			self = .array(value)
		} else if let value = try? container.decode([String: Deluge.Value].self) {
			self = .dictionary(value)
		} else {
			throw DecodingError.dataCorruptedError(
				in: container,
				debugDescription: "Unsupported JSON value"
			)
		}
	}
}

extension Deluge.Value: Encodable {
	public func encode(to encoder: any Encoder) throws {
		var container = encoder.singleValueContainer()

		switch self {
		case let .string(value): try container.encode(value)
		case let .int(value): try container.encode(value)
		case let .double(value): try container.encode(value)
		case let .bool(value): try container.encode(value)
		case let .array(value): try container.encode(value)
		case let .dictionary(value): try container.encode(value)
		case .null: try container.encodeNil()
		}
	}
}

public extension Deluge.Value {
	/// The underlying value as `Any`, suitable for use as a request argument.
	var rpcValue: Any {
		switch self {
		case let .string(value): value
		case let .int(value): value
		case let .double(value): value
		case let .bool(value): value
		case let .array(value): value.map(\.rpcValue)
		case let .dictionary(value): value.mapValues(\.rpcValue)
		case .null: NSNull()
		}
	}
}
