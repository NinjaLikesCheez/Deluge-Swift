import APIClient

public extension DelugeRequest {
	/// Attempts to authenticate with the server. This will produce a `Void` value if authenticated.
	///
	/// RPC Method: `auth.login`
	static func authenticate(_ password: String) -> DelugeRequest<Bool> {
		.init(
			method: "auth.login",
			args: [password]
		)
	}

	/// Checks whether the current session is still valid.
	///
	/// RPC Method: `auth.check_session`
	static var checkSession: DelugeRequest<Bool> {
		.init(method: "auth.check_session", args: [])
	}

	/// Deletes the current session, logging the client out.
	///
	/// RPC Method: `auth.delete_session`
	static var deleteSession: DelugeRequest<Bool> {
		.init(method: "auth.delete_session", args: [])
	}

	/// Changes the account password.
	///
	/// RPC Method: `auth.change_password`
	///
	/// - Parameters:
	///   - oldPassword: The current password.
	///   - newPassword: The new password to set.
	static func changePassword(oldPassword: String, newPassword: String) -> DelugeRequest<Bool> {
		.init(method: "auth.change_password", args: [oldPassword, newPassword])
	}
}
