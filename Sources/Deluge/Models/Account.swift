/// A known Deluge user account, as returned by `core.get_known_accounts`.
public struct Account: Decodable, Equatable, Hashable, Sendable {
	/// The account's username.
	public let username: String
	/// The account's password.
	public let password: String
	/// The account's named authentication level.
	public let authLevel: AuthLevel
	/// The account's authentication level, as its underlying integer value.
	public let authLevelValue: Int

	enum CodingKeys: String, CodingKey {
		case username
		case password
		case authLevel = "authlevel"
		case authLevelValue = "authlevel_int"
	}
}
