import Foundation

/// Errors that can occur during Deluge operations.
public enum DelugeError: Swift.Error {
    /// An error occurred while encoding the request.
    case encoding(Swift.Error)
    /// An error occurred while decoding the response.
    case decoding(Swift.Error)
    /// A request error occurred.
    case request(URLError)
    /// An unknown request error occurred.
    case unknownRequestError(Swift.Error)
    /// The provided authentication was not valid.
    case unauthenticated
    /// The server returned an unexpected response.
    case unexpectedResponse
    /// The server returned an error message.
    case serverError(message: String?)
    /// The server already has this torrent - this is a bug in deluge
    case torrentAlreadyAddedException
    /// The server is up, but no host is connected
    case unconnected
}

