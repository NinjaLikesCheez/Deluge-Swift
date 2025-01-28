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
}
