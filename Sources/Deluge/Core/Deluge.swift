@_exported import APIClient
import Foundation
import Logging

#if canImport(Combine)
    import Combine
#endif

// URLSession in exists in FoundationNetworking on Linux
#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif

/// A Deluge JSON-RPC API client.
public final class Deluge: Client, Sendable {
    public typealias ResponseError = DelugeResponseError
    public typealias Error = ClientError<ResponseError>

    /// The URL of the Deluge server.
    public let baseURL: URL
    /// The password used for authentication.
    public let password: String
    /// Basic authentication to be added to Authorization header.
    public let basicAuthentication: BasicAuthentication?
    public let defaultHeaders: APIClient.HTTPFields?

    public let decoder: JSONDecoder = .init()

    public let validate: @Sendable (Data, HTTPURLResponse) throws(APIClient.ClientError<DelugeResponseError>) -> Void

    public let prepare: @Sendable (URLRequest) -> URLRequest

    public let session: URLSession = .shared

    private let logger = Logger(label: "Deluge")

    /// Creates a Deluge client to interact with the given server URL.
    /// - Parameters:
    ///   - baseURL: The URL of the Deluge server.
    ///   - password: The password used for authentication.
    public init(baseURL: URL, password: String, basicAuthentication: BasicAuthentication? = nil) {
        self.baseURL = baseURL.appending(path: "json")
        self.password = password
        self.basicAuthentication = basicAuthentication

        defaultHeaders = ["Content-Type": "application/json"]
        prepare = { $0 }
        validate = Self.validate
    }

    @Sendable
    private static func validate(data: Data, response: HTTPURLResponse) throws(Deluge.Error) {
        guard response.statusCode == 200 else {
            throw .response(.message("Server returned non-200 status code: \(response.statusCode)"))
        }

        // Deluge returns 200, even for errors - which are wrapped in the response
        let response: Response<EmptyResponse>

        do {
            response = try JSONDecoder().decode(Response<EmptyResponse>.self, from: data)
        } catch let error as DecodingError {
            throw .decoding(error)
        } catch {
            throw .response(.unknown(error))
        }

        guard let error = response.error else { return }

        if error.code == 1 {
            throw .response(.unauthenticated)
        }

        let parts = [
            // "<class 'Deluge.Error.AddTorrentError'>: Torrent already in session",
            "Torrent already in session",
            // "<class 'Deluge.Error.WrappedException'>: type <class 'Deluge.Error.AddTorrentError'> not handled",
            "Deluge.Error.AddTorrentError",
        ]

        if parts.map({ error.message.contains($0) }).contains(true) {
            throw .response(.torrentAlreadyInSession)
        }

        throw .response(.message(error.message))
    }
}

#if canImport(Combine)
    /// Combine-powered extensions for `Deluge`.
    public extension Deluge {
        /// Sends a request to the server.
        /// - Parameter request: The request to be sent to the server.
        /// - Returns: A publisher that emits a value when the request completes.
        func request<Value: Decodable>(_ request: DelugeRequest<Value>) -> AnyPublisher<Value, Deluge.Error> {
            let retryIfNeeded = { (error: Deluge.Error) -> AnyPublisher<Value, Deluge.Error> in
                switch error {
                case .response(.unconnected):
                    // Attempt to connect to the host, if there is only one host
                    self.send(request: DelugeRequest<[Host]>.hosts)
                        .flatMap { hosts in
                            guard hosts.count == 1, let host = hosts.first else {
                                return Fail<EmptyResponse, Deluge.Error>(error: .response(.unconnected))
                                    .eraseToAnyPublisher()
                            }

                            return self.send(request: DelugeRequest<EmptyResponse>.connect(to: host.id))
                                .eraseToAnyPublisher()
                        }
                        .flatMap { _ in
                            self.send(request: request)
                                .eraseToAnyPublisher()
                        }
                        .eraseToAnyPublisher()
                case .response(.unauthenticated):
                    self.send(request: DelugeRequest<Bool>.authenticate(self.password))
                        .flatMap { authenticated in
                            if !authenticated {
                                return Fail<Value, Deluge.Error>(
                                    error: Deluge.Error.response(.unauthenticated)
                                ).eraseToAnyPublisher()
                            }

                            return self.send(request: request)
                        }
                        .eraseToAnyPublisher()
                default:
                    Fail<Value, Deluge.Error>(error: error)
                        .eraseToAnyPublisher()
                }
            }

            return send(request: request)
                .catch(retryIfNeeded)
                .eraseToAnyPublisher()
        }
    }
#endif

/// Swift Concurrency powered extensions for `Deluge`.
public extension Deluge {
    /// Sends a request to the server.
    /// - Parameter request: The request to be sent to the server.
    /// - Returns: A publisher that emits a value when the request completes.
    @discardableResult
    func request<Value: Decodable>(_ request: DelugeRequest<Value>) async throws(Deluge.Error) -> Value {
        do {
            return try await send(request: request)
        } catch {
            switch error {
            case .response(.unconnected):
                let hosts = try await self.request(DelugeRequest<[Host]>.hosts)
                guard hosts.count == 1, let host = hosts.first else {
                    throw error
                }

                try await send(request: DelugeRequest<EmptyResponse>.connect(to: host.id))

                return try await send(request: request)
            case .response(.unauthenticated):
                try await send(request: DelugeRequest<Bool>.authenticate(password))
                return try await send(request: request)
            default:
                throw error
            }
        }
    }
}
