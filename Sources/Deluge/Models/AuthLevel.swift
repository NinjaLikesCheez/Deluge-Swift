/// A named authentication level used by Deluge's account management RPC methods.
public struct AuthLevel: RawRepresentable, Equatable, Hashable, Codable, Sendable {
	public typealias RawValue = String

	public let rawValue: String

	public init(rawValue: String) {
		self.rawValue = rawValue
	}
}

public extension AuthLevel {
	/// No access.
	static let none = AuthLevel(rawValue: "NONE")
	/// Read-only access.
	static let readOnly = AuthLevel(rawValue: "READONLY")
	/// The default access level for new accounts.
	static let `default` = AuthLevel(rawValue: "DEFAULT")
	/// Normal access.
	static let normal = AuthLevel(rawValue: "NORMAL")
	/// Full administrative access.
	static let admin = AuthLevel(rawValue: "ADMIN")
}
