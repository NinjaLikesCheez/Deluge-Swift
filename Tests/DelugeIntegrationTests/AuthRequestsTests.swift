import Deluge
import Testing

#if canImport(Combine)
	import Combine
#endif

@Suite("Authentication Requests", .serialized)
struct AuthRequestsTests {
	#if canImport(Combine)
		@Test
		func test_authenticate() async throws {
			for try await authenticated in client.request(.authenticate(TestConfig.serverPassword)).values {
				#expect(authenticated == true)
			}
		}
	#endif

	@Test
	func test_authenticate_concurrency() async throws {
		let authenticated = try await client.request(.authenticate(TestConfig.serverPassword))
		#expect(authenticated == true)
	}

	#if canImport(Combine)
		@Test
		func test_checkSession() async throws {
			_ = try await client.request(.authenticate(TestConfig.serverPassword))
			for try await isValid in client.request(.checkSession).values {
				#expect(isValid == true)
			}
		}
	#endif

	@Test
	func test_checkSession_concurrency() async throws {
		_ = try await client.request(.authenticate(TestConfig.serverPassword))
		let isValid = try await client.request(.checkSession)
		#expect(isValid == true)
	}

	#if canImport(Combine)
		@Test
		func test_changePassword() async throws {
			_ = try await client.request(.authenticate(TestConfig.serverPassword))
			for try await changed in client.request(
				.changePassword(oldPassword: TestConfig.serverPassword, newPassword: TestConfig.serverPassword)
			).values {
				#expect(changed == true)
			}
		}
	#endif

	@Test
	func test_changePassword_concurrency() async throws {
		_ = try await client.request(.authenticate(TestConfig.serverPassword))
		let changed = try await client.request(
			.changePassword(oldPassword: TestConfig.serverPassword, newPassword: TestConfig.serverPassword)
		)
		#expect(changed == true)
	}

	// These must remain the last tests in this suite: `auth.delete_session` logs the client out, and while
	// `Deluge` automatically re-authenticates on the next request after an `.unauthenticated` error, running
	// this before other tests risks interfering with them.
	#if canImport(Combine)
		@Test
		func test_zzDeleteSession() async throws {
			_ = try await client.request(.authenticate(TestConfig.serverPassword))
			for try await deleted in client.request(.deleteSession).values {
				#expect(deleted == true)
			}
		}
	#endif

	@Test
	func test_zzDeleteSession_concurrency() async throws {
		_ = try await client.request(.authenticate(TestConfig.serverPassword))
		let deleted = try await client.request(.deleteSession)
		#expect(deleted == true)
	}
}
