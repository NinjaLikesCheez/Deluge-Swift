import Foundation
@_exported import APIClient

public typealias Deluge = Client

public extension Deluge {
    struct BasicAuthentication: Equatable, Codable {
        public let username: String
        public let password: String

        public init(username: String, password: String) {
            self.username = username
            self.password = password
        }

        var encoded: String? {
            "\(username):\(password)"
                .data(using: .utf8)?
                .base64EncodedString()
        }
    }

    convenience init(baseURL: URL, password: String, basicAuthentication: BasicAuthentication? = nil) {
        var headers = [
            "Content-Type": "application/json",
        ]

        if let basicAuthentication {
            headers["Authorization"] = "Basic \(basicAuthentication.encoded!)"
        }

        self.init(
            baseURL: baseURL,
            defaultHeaders: headers,
            validate: { data, response throws(Client.Error) in
                guard response.statusCode == 200 else {
                    throw .serverError("Server returned status code: \(response.statusCode)")
                }

                // Deluge returns 200, even for errors - which are wrapped in the response
                let response: DelugeResponse<EmptyResponse>

                do {
                    response = try JSONDecoder().decode(DelugeResponse<EmptyResponse>.self, from: data)
                    guard let error = response.error else { return }
                } catch let error as DecodingError {
                    throw .decoding(error)
                } catch {
                    throw .unexpectedResponse(error)
                }

                if response.error?.code == 1 {
                    throw .unauthenticated
                } else if let message = response.error?.message {
                    let parts = [
                        // "<class 'deluge.error.AddTorrentError'>: Torrent already in session",
                        "Torrent already in session",
                        // "<class 'deluge.error.WrappedException'>: type <class 'deluge.error.AddTorrentError'> not handled",
                        "deluge.error.AddTorrentError",
                    ]

                    if parts.map({ message.contains($0) }).contains(true) {
                        throw .unknown(DelugeError.torrentAlreadyAddedException)
                    }

                    throw .serverError(message)
                }
            },
            retryAuthenticationAsync: { client in
                (try? await client.request(.authenticate(password))) ?? false
            },
            retryAuthenticationPublisher: { client in
                client.request(.authenticate(password))
            }
        )
    }
}

func delugeFormatBody(_ method: String, parameters: [Any]) -> [String: Any] {
    [
        "id": 1,
        "method": method,
        "params": parameters
    ]
}

public extension Request {
    init(
        method: String,
        args: [Any],
        autenticateIfNeeded: Bool = true,
        transform: ((Data) throws -> Value)? = nil
    ) {
        self = .init(
            method: .post,
            path: nil,
            body: delugeFormatBody(method, parameters: args),
            transform: transform ?? {
                do {
                    let response = try JSONDecoder().decode(DelugeResponse<Value>.self, from: $0)

                    if response.error?.code == 1 {
                        throw Client.Error.transformError(DelugeError.unauthenticated)
                    } else if let message = response.error?.message {
                        throw Client.Error.serverError(message)
                    }

                    return response.result
                } catch let error as Client.Error {
                    throw error
                } catch {
                    throw Client.Error.decoding(error)
                }
            }
        )
    }
}
