# AGENTS.md

This file provides guidance to Claude Code (claude.ai/code) and other coding agents when working with code in this repository. `CLAUDE.md` is a symlink to this file.

## What this is

A Combine/Swift Concurrency-powered Deluge JSON-RPC API client (Swift package, `swift-tools-version:6.0`). It builds on top of the [swift-api-client](https://github.com/NinjaLikesCheez/swift-api-client) package (`APIClient` module), which provides the generic `Client`/`Request` protocol machinery. This repo layers Deluge-specific request types, models, and error handling on top of that.

## Commands

- Build: `swift build`
- Format (in place): `scripts/format.sh`
- Lint (check only): `scripts/lint.sh` — use `scripts/lint.sh --strict` to match CI
- Full CI sequence locally: `scripts/run_ci.sh` (requires a clean git tree; fails if `scripts/format.sh` produces changes, then lints strictly, then does a clean `swift build`)
- Run unit/non-integration tests: `swift test --skip DelugeIntegrationTests`
- Run a single test: `swift test --filter <TestClassName>/<testMethodName>`
- Run integration tests against a real Deluge daemon in Docker/Podman: `scripts/run_integration_tests.sh` (spins up `linuxserver/deluge`, runs `swift test --no-parallel --filter DelugeIntegrationTests`, tears the container down). Integration tests must run with `--no-parallel`/serialized — see `Deluge.xctestplan`, which marks `DelugeIntegrationTests` as not parallelizable, and [Tests/DelugeIntegrationTests/IntegrationTestCase.swift](Tests/DelugeIntegrationTests/IntegrationTestCase.swift), which shares a single `client`/daemon instance across the suite. Don't re-enable parallelization for this target — it caused cross-suite races previously.

Formatting/linting uses `xcrun swift-format` with the config in `.swift-format` (tabs, 120 col line length, enforced import ordering). CI (`.github/workflows/ci.yml`) runs on `macos-15` via `scripts/run_ci.sh` and will fail if code isn't pre-formatted.

### Container hygiene when testing against a Deluge daemon

Whenever a task calls for testing against a live Deluge daemon — running `scripts/run_integration_tests.sh`, or manually poking at one with `docker`/`podman` — always spin up your own fresh container rather than attaching to, reusing, or touching whatever Deluge container(s) may already be running on the host. Never stop, remove, or restart a pre-existing container you didn't start yourself, even if it looks idle or is also named `linuxserver/deluge` — it may belong to the user or another process. Once testing is finished, stop and remove (pull down) only the container you created.

- `scripts/run_integration_tests.sh` already follows this pattern for CI/local runs (a dedicated `DelugeIntegrationTests` container is stopped/removed only if a prior run of that same script left one behind, then torn down again at the end) — prefer that script for anything the integration test suite covers.
- For ad-hoc/manual testing outside that script, `docker run -d --name <your-own-unique-name> linuxserver/deluge` (or the `podman` equivalent) and `docker stop`/`docker rm` that same name when done.

## Architecture

### Request/Response flow

- `Deluge` ([Sources/Deluge/Core/Deluge.swift](Sources/Deluge/Core/Deluge.swift)) is the main client, conforming to `Client` from `APIClient`. It holds the `baseURL` (with `/json` appended), `password`, optional basic auth, and a shared `validate` closure.
- Every RPC call is expressed as a `DelugeRequest<Response>` ([Sources/Deluge/Core/DelugeRequest.swift](Sources/Deluge/Core/DelugeRequest.swift)), constructed with a JSON-RPC `method` name and `args` array. The body is serialized as `{"id": 1, "method": ..., "params": [...]}`.
- Concrete requests live under `Sources/Deluge/Requests/` (e.g. `AuthRequests.swift`, `CoreRequests.swift`, `LabelRequests.swift`, `WebRequests.swift`) as static factory methods/properties on `DelugeRequest`, e.g. `DelugeRequest<Bool>.authenticate(password)`. When adding a new RPC method, follow this pattern: add a static factory in the relevant `*Requests.swift` file rather than constructing `DelugeRequest` inline at call sites.
- Deluge's JSON-RPC server always returns HTTP 200, even for errors — real errors are wrapped inside the JSON body (`Deluge.Response<Value>.error`, see [Sources/Deluge/Core/Deluge+Response.swift](Sources/Deluge/Core/Deluge+Response.swift)). `Deluge.validate(data:response:)` decodes this envelope and translates known error codes (`DelugeErrorCode` in [Sources/Deluge/Core/DelugeError.swift](Sources/Deluge/Core/DelugeError.swift)) into typed `DelugeResponseError` cases.

### Reconnect/re-auth retry logic

Both the Combine (`Deluge.request` returning `AnyPublisher`) and async/await (`Deluge.request` async throws) entry points in `Deluge.swift` wrap the lower-level `send(request:)` from `APIClient` with the same retry behavior — keep them in sync if you change one:

- `.response(.unconnected)`: Deluge reports "unknown RPC method" identically whether the web UI genuinely doesn't have that method, or simply hasn't connected to a daemon host yet. The client treats this as `.unconnected`, looks up hosts via `DelugeRequest<[Host]>.hosts`, and if there's exactly one host, connects to it and retries the original request once. If the retry hits `.unconnected` again, it's surfaced as `.unknownMethod` instead (real missing method, not a connectivity issue).
- `.response(.unauthenticated)`: re-authenticates via `auth.login` using the stored `password`, then retries the original request once.
- Both retries only happen once — there is no unbounded retry loop.

### Error model

Two layers of errors: `DelugeError`/`DelugeRequestError`/`DelugeResponseError` in `DelugeError.swift` are the domain-level error enums; `Deluge.Error` (used as the client's associated `Error` type) is `APIClient.ClientError<DelugeResponseError>`. `DelugeResponseError.fromAPIError` maps raw JSON-RPC error codes/messages (including a known Deluge daemon bug where adding an already-added torrent returns a Python stacktrace instead of a clean error) into typed cases like `.torrentAlreadyInSession`.

### Models

`Sources/Deluge/Models/` contains `Decodable` types returned by requests (`Torrent`, `TorrentItem`, `TorrentFile`, `Tracker`, `Label`, `Host`, `Priority`, `Plugins`, `RemoveTorrentError`, `TorrentsAndLabels`) — check here before adding a new model type in case an existing one already fits.

### Platform support

Cross-platform (iOS 18+, tvOS 18+, macOS 15+, and Linux via SwiftPM): guards around `canImport(Combine)` and `canImport(FoundationNetworking)` exist because Combine and `URLSession` availability differ on Linux — preserve these guards when touching `Deluge.swift`.

### Tests

- `Tests/DelugeIntegrationTests/` is the only test target, split into non-integration unit-style tests (e.g. `BadMethodTests.swift`) and true integration tests (`AuthRequestsTests.swift`, `CoreRequestsTests.swift`, `LabelRequestsTests.swift`, `SetOptionTests.swift`, `WebRequestsTests.swift`) that hit a real Deluge daemon.
- `TestConfig.swift` centralizes fixture data (server URL/password, known torrent hashes/files, magnet/web URLs) used across integration tests; add new fixtures there rather than inlining them.
- `IntegrationTestCase.swift` defines a single shared `client` instance used across the whole integration suite — tests are not isolated per-instance, which is why the suite must run serialized.

## Style & Conventions

Formatting itself (indentation, line length, import order) is enforced mechanically by `scripts/format.sh`/`scripts/lint.sh` — don't hand-format, just run the script. The conventions below are things the tooling won't catch.

### Doc comments

- Every public type, property, and function gets a one-line `///` summary above it. For request factories, follow the established three-part shape used throughout `Sources/Deluge/Requests/`:
  ```swift
  /// <What it does, one sentence.>
  ///
  /// RPC Method: `<deluge.rpc_method_name>`
  ///
  /// Result: <what the response value represents> (omit this line if the response is `EmptyResponse`/`Bool` and self-explanatory)
  ///
  /// - Parameter(s): <standard swift-doc parameter block>
  static func foo(...) -> DelugeRequest<...> { ... }
  ```
- Model properties each get their own `///` line directly above the property, not a block comment above the whole type. See [Sources/Deluge/Models/Torrent.swift](Sources/Deluge/Models/Torrent.swift) for the pattern, including how `CodingKey`-backed enums document which raw API key each case maps to (e.g. `/// Requests the key `time_added` from the API.`).
- Non-obvious behavior (quirky server bugs, retry semantics, ordering constraints) gets explained in a regular `//` comment at the point of the workaround, with enough context to stand alone — see the `.unconnected`/`.unknownMethod` handling in [Sources/Deluge/Core/Deluge.swift](Sources/Deluge/Core/Deluge.swift) and the AddTorrentError handling in [Sources/Deluge/Core/DelugeError.swift](Sources/Deluge/Core/DelugeError.swift). Don't write comments that just restate what the code does.

### Naming & API shape

- Request factories read as a fluent sentence at the call site: `client.request(.authenticate(password))`, `.add(magnetURL:)`, `.queueTop(hashes:)`. Prefer overloaded static funcs distinguished by argument label (`add(fileURL:)`, `add(fileURLs:)`, `add(magnetURL:)`, `add(url:)`) over inventing distinct verbs per variant.
- Static factories with no arguments are computed `var`s (e.g. `checkSession`, `deleteSession`, `hosts`), not `func()`.
- Model properties use Swift naming (`downloadPath`, `seedingTime`) and map to Deluge's snake_case wire format via an explicit `PropertyKeys: String, CodingKey` enum rather than a custom `CodingKeys` per-model or a global snake_case conversion strategy.
- Prefer `Equatable, Decodable, Sendable` conformances on model structs as a matter of course (see `Torrent`, `Host`, `Priority`, `Tracker`).

### Error handling

- Don't introduce new untyped `throws` where a typed error already models the failure — this codebase uses typed throws (`throws(Deluge.Error)`) at the public API boundary in `Deluge.swift`. Match that when extending client-level entry points.
- Model errors as enum cases with associated data rather than stringly-typed errors, and give each case a `///` doc comment explaining when it occurs (see `DelugeResponseError`).
- When a Deluge daemon quirk needs a workaround (ambiguous error codes, buggy stacktrace-as-message responses), encode the detection logic where the error is produced (`DelugeResponseError.fromAPIError`, `Deluge.validate`) rather than downstream at call sites, and link the upstream bug/ticket in a comment if one exists.

### Requests vs. models

- New RPC methods are added as static factories in the relevant `Sources/Deluge/Requests/*Requests.swift` file (grouped by Deluge RPC namespace: `auth.*` → `AuthRequests.swift`, `core.*` → `CoreRequests.swift`, `label.*` → `LabelRequests.swift`, `web.*` → `WebRequests.swift`), never constructed inline at the call site.
- Custom response parsing (when the default `Deluge.Response<Value>` decode isn't enough, e.g. `core.remove_torrents`' paired-array result) goes in the request's `transform` closure, not as a separate free function or extension.

### Tests

- Tests use **Swift Testing** (`import Testing`, `@Suite`, `@Test`, `#expect`), not XCTest.
- Integration test suites are annotated `@Suite("...", .serialized)` — new integration suites should follow this since they share the single global `client`.
- Where a request has both a Combine and async/await entry point, write matching test pairs: `test_foo()` (wrapped in `#if canImport(Combine)`, iterating `.values`) and `test_foo_concurrency()` (plain `async throws`). Keep both in sync when behavior changes.
- Tests that must run last within a suite (e.g. because they invalidate session state) are prefixed `zz` (`test_zzDeleteSession`) with a comment explaining why, rather than relying on incidental file/declaration order.
