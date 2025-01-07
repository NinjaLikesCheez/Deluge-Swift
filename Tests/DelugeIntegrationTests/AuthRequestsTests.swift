import Deluge
import Combine
import Testing

@Suite("Authentication Requests", .serialized)
class AuthRequestsTests: IntegrationTestCase {
    @Test
    func test_authenticate() async {
        // TODO: convert _all_ combine tests to use withCheckedContinutation
        await withCheckedContinuation { continuation in
            client.request(.authenticate(TestConfig.serverPassword))
                .sink(
                    receiveCompletion: { completion in
                        if case let .failure(error) = completion {
                            Issue.record(error, "Failed to authenticate")
                        }
                    },
                    receiveValue: { value in
                        #expect(value)
                        continuation.resume()
                    }
                )
                .store(in: &cancellables)
        }
    }

    @Test
    func test_authenticate_concurrency() async throws {
        let result = try await client.request(.authenticate(TestConfig.serverPassword))
        #expect(result, "Authentication failed")
    }
}
