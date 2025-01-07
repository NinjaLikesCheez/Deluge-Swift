import Deluge
import Combine
import Testing

@Suite("Bad Method", .serialized)
class BadMethodTests: IntegrationTestCase {
    @Test
    func test_badMethod() async {
        await withCheckedContinuation { continuation in
            let bad = Request<EmptyResponse>(method: "bad", args: [])

            client.request(bad)
                .sink(
                    receiveCompletion: { completion in
                        if case let .failure(error) = completion, case .serverError = error {
                            // success
                            continuation.resume()
                        } else {
                            Issue.record("Expected failure")
                        }
                    },
                    receiveValue: { _ in
                        Issue.record("Should not receive value")
                    }
                )
                .store(in: &cancellables)
        }
    }

    @Test
    func test_badMethod_concurrency() async throws {
        let bad = Request<EmptyResponse>(method: "bad", args: [])

        do {
            _ = try await client.request(bad)
        } catch {
            if case .serverError = error {
                // success
            } else {
                Issue.record("Expected server error")
            }
        }
    }
}
