import Deluge
import Testing

#if canImport(Combine)
	import Combine
#endif

@Suite("Account Requests", .serialized)
struct AccountRequestsTests {
	#if canImport(Combine)
		@Test
		func test_authLevelsMappings() async throws {
			for try await mappings in client.request(.authLevelsMappings).values {
				#expect(mappings.nameToValue["ADMIN"] == 10)
				#expect(mappings.valueToName[10] == "ADMIN")
			}
		}
	#endif

	@Test
	func test_authLevelsMappings_concurrency() async throws {
		let mappings = try await client.request(.authLevelsMappings)
		#expect(mappings.nameToValue["ADMIN"] == 10)
		#expect(mappings.valueToName[10] == "ADMIN")
	}

	#if canImport(Combine)
		@Test
		func test_createAccount_knownAccounts_updateAccount_removeAccount() async throws {
			try await ensureAccountRemoved("test-account", from: client)

			for try await created in client.request(
				.createAccount(username: "test-account", password: "password1", authLevel: .normal)
			).values {
				#expect(created == true)
			}

			for try await accounts in client.request(.knownAccounts).values {
				let account = accounts.first { $0.username == "test-account" }
				#expect(account?.authLevel == .normal)
			}

			for try await updated in client.request(
				.updateAccount(username: "test-account", password: "password2", authLevel: .admin)
			).values {
				#expect(updated == true)
			}

			for try await accounts in client.request(.knownAccounts).values {
				let account = accounts.first { $0.username == "test-account" }
				#expect(account?.authLevel == .admin)
			}

			for try await removed in client.request(.removeAccount(username: "test-account")).values {
				#expect(removed == true)
			}

			for try await accounts in client.request(.knownAccounts).values {
				#expect(!accounts.contains { $0.username == "test-account" })
			}
		}
	#endif

	@Test
	func test_createAccount_knownAccounts_updateAccount_removeAccount_concurrency() async throws {
		try await ensureAccountRemoved("test-account-concurrency", from: client)

		let created = try await client.request(
			.createAccount(username: "test-account-concurrency", password: "password1", authLevel: .normal)
		)
		#expect(created == true)

		let accounts = try await client.request(.knownAccounts)
		let account = accounts.first { $0.username == "test-account-concurrency" }
		#expect(account?.authLevel == .normal)
		#expect(account?.authLevelValue == 5)

		let updated = try await client.request(
			.updateAccount(username: "test-account-concurrency", password: "password2", authLevel: .admin)
		)
		#expect(updated == true)

		let accountsAfterUpdate = try await client.request(.knownAccounts)
		let updatedAccount = accountsAfterUpdate.first { $0.username == "test-account-concurrency" }
		#expect(updatedAccount?.authLevel == .admin)
		#expect(updatedAccount?.authLevelValue == 10)

		let removed = try await client.request(.removeAccount(username: "test-account-concurrency"))
		#expect(removed == true)

		let accountsAfterRemoval = try await client.request(.knownAccounts)
		#expect(!accountsAfterRemoval.contains { $0.username == "test-account-concurrency" })
	}

	@Test
	func test_createAccount_duplicateUsername_concurrency() async throws {
		try await ensureAccountRemoved("test-account-duplicate", from: client)
		_ = try await client.request(
			.createAccount(username: "test-account-duplicate", password: "password1", authLevel: .normal)
		)

		await #expect(throws: Deluge.Error.self) {
			try await client.request(
				.createAccount(username: "test-account-duplicate", password: "password1", authLevel: .normal)
			)
		}

		try await ensureAccountRemoved("test-account-duplicate", from: client)
	}
}
