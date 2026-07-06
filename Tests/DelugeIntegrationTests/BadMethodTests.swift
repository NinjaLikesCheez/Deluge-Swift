import APIClient
import Deluge
import Testing

#if canImport(Combine)
	import Combine
#endif

@Suite("Bad Method", .serialized)
struct BadMethodTests {
	#if canImport(Combine)
		@Test
		func test_badMethod() async {
			let bad = DelugeRequest<EmptyResponse>(method: "bad", args: []) { _ in
				throw Deluge.Error.response(.message(nil))
			}

			await confirmation { confirmation in
				do {
					for try await _ in client.request(bad).values {
						Issue.record("Should not recieve value")
					}
				} catch let error as Deluge.Error {
					switch error {
					case .response(.unknownMethod):
						confirmation.confirm()
					default:
						Issue.record("Unexpected error: \(error)")
					}
				} catch {
					Issue.record("Unexpected error: \(error)")
				}
			}
		}
	#endif

	@Test
	func test_badMethod_concurrency() async throws {
		let bad = DelugeRequest<EmptyResponse>(method: "bad", args: []) { _ in
			throw Deluge.Error.response(.message(nil))
		}

		do {
			try await client.request(bad)
			Issue.record("Expected error")
		} catch {
			switch error {
			case .response(.unknownMethod):
				break
			default:
				Issue.record("Unexpected error: \(error)")
			}
		}
	}
}
