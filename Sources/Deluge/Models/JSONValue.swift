import Foundation

/// A JSON value of unknown shape, used for RPC methods that return or accept free-form dictionaries.
public enum JSONValue: Equatable, Sendable {
	/// A string value.
	case string(String)
	/// A numeric value.
	case number(Double)
	/// A boolean value.
	case bool(Bool)
	/// An array of values.
	case array([JSONValue])
	/// An object of values.
	case object([String: JSONValue])
	/// A null value.
	case null
}

extension JSONValue: Decodable {
	public init(from decoder: any Decoder) throws {
		let container = try decoder.singleValueContainer()

		if container.decodeNil() {
			self = .null
		} else if let bool = try? container.decode(Bool.self) {
			self = .bool(bool)
		} else if let number = try? container.decode(Double.self) {
			self = .number(number)
		} else if let string = try? container.decode(String.self) {
			self = .string(string)
		} else if let array = try? container.decode([JSONValue].self) {
			self = .array(array)
		} else if let object = try? container.decode([String: JSONValue].self) {
			self = .object(object)
		} else {
			throw DecodingError.dataCorruptedError(
				in: container,
				debugDescription: "Value is not a valid JSON value"
			)
		}
	}
}

public extension JSONValue {
	/// Converts this value into a plain Swift value suitable for use as an RPC argument (`String`, `Int`, `Double`,
	/// `Bool`, `[Any]`, `[String: Any]`, or `NSNull`).
	var rpcValue: Any {
		switch self {
		case let .string(string):
			return string
		case let .number(number):
			return number
		case let .bool(bool):
			return bool
		case let .array(array):
			return array.map(\.rpcValue)
		case let .object(object):
			return object.mapValues(\.rpcValue)
		case .null:
			return NSNull()
		}
	}
}
