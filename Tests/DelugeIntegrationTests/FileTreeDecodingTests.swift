import Deluge
import Foundation
import Testing

#if canImport(FoundationNetworking)
	import FoundationNetworking
#endif

// Decoding-only tests (no daemon required) for the file/directory trees returned by
// `web.get_torrent_files` and `web.get_torrent_info`. The payloads below were captured from
// Deluge 2.x (`WebApi._on_got_files` and `uicommon.TorrentInfo`) for a torrent laid out as:
//
//	My Torrent/
//	├── data.bin (index 1, 200 bytes)
//	└── docs/
//	    └── readme.txt (index 0, 100 bytes)
@Suite("File Tree Decoding")
struct FileTreeDecodingTests {
	private let httpResponse = HTTPURLResponse(
		url: URL(string: "http://localhost:8112/json")!,
		statusCode: 200,
		httpVersion: nil,
		headerFields: nil
	)!

	private static let torrentFilesMultiFilePayload = """
		{
			"id": 1,
			"error": null,
			"result": {
				"type": "dir",
				"contents": {
					"My Torrent": {
						"type": "dir",
						"path": "My Torrent",
						"size": 300,
						"progress": 0.6666666666666667,
						"progresses": [1.0, 1.0],
						"priority": 9,
						"contents": {
							"data.bin": {
								"type": "file",
								"index": 1,
								"offset": 100,
								"path": "My Torrent/data.bin",
								"size": 200,
								"progress": 0.5,
								"priority": 7
							},
							"docs": {
								"type": "dir",
								"path": "My Torrent/docs",
								"size": 100,
								"progress": 1.0,
								"progresses": [1.0],
								"priority": 4,
								"contents": {
									"readme.txt": {
										"type": "file",
										"index": 0,
										"offset": 0,
										"path": "My Torrent/docs/readme.txt",
										"size": 100,
										"progress": 1.0,
										"priority": 4
									}
								}
							}
						}
					}
				}
			}
		}
		"""

	private static let torrentFilesSingleFilePayload = """
		{
			"id": 1,
			"error": null,
			"result": {
				"type": "dir",
				"contents": {
					"single.iso": {
						"type": "file",
						"index": 0,
						"offset": 0,
						"path": "single.iso",
						"size": 300,
						"progress": 1.0,
						"priority": 4
					}
				}
			}
		}
		"""

	private static let torrentInfoMultiFilePayload = """
		{
			"id": 1,
			"error": null,
			"result": {
				"name": "My Torrent",
				"info_hash": "729eb67fe32b4b502f788f992ef07d3f22945a9e",
				"files_tree": {
					"type": "dir",
					"contents": {
						"My Torrent": {
							"type": "dir",
							"download": true,
							"length": 300,
							"contents": {
								"data.bin": {
									"type": "file",
									"download": true,
									"index": 1,
									"length": 200,
									"path": "My Torrent/data.bin"
								},
								"docs": {
									"type": "dir",
									"download": true,
									"length": 100,
									"contents": {
										"readme.txt": {
											"type": "file",
											"download": true,
											"index": 0,
											"length": 100,
											"path": "My Torrent/docs/readme.txt"
										}
									}
								}
							}
						}
					}
				}
			}
		}
		"""

	private func decodeTorrentItems(from payload: String) throws -> [TorrentItem] {
		let transform = try #require(DelugeRequest<[TorrentItem]>.torrentItems(hash: "unused").transform)
		return try transform(Data(payload.utf8), httpResponse)
	}

	@Test
	func test_torrentItems_decodesDirectories() throws {
		let items = try decodeTorrentItems(from: Self.torrentFilesMultiFilePayload)

		#expect(items.count == 1)
		guard case let .directory(rootName, rootItems) = items.first else {
			Issue.record("Expected a root directory, got \(String(describing: items.first))")
			return
		}
		#expect(rootName == "My Torrent")
		#expect(rootItems.count == 2)

		let expectedFile = TorrentItem.file(
			TorrentFile(
				index: 1,
				name: "data.bin",
				path: "My Torrent/data.bin",
				size: 200,
				progress: 0.5,
				priority: .high
			)
		)
		#expect(rootItems.contains(expectedFile))

		let expectedSubdirectory = TorrentItem.directory(
			name: "docs",
			items: [
				.file(
					TorrentFile(
						index: 0,
						name: "readme.txt",
						path: "My Torrent/docs/readme.txt",
						size: 100,
						progress: 1.0,
						priority: .normal
					)
				)
			]
		)
		#expect(rootItems.contains(expectedSubdirectory))
	}

	@Test
	func test_torrentItems_decodesSingleFile() throws {
		let items = try decodeTorrentItems(from: Self.torrentFilesSingleFilePayload)

		let expectedFile = TorrentItem.file(
			TorrentFile(index: 0, name: "single.iso", path: "single.iso", size: 300, progress: 1.0, priority: .normal)
		)
		#expect(items == [expectedFile])
	}

	@Test
	func test_torrentInfo_decodesDirectories() throws {
		let transform = try #require(DelugeRequest<TorrentFileInfo?>.torrentInfo(filename: "unused").transform)
		let decoded = try transform(Data(Self.torrentInfoMultiFilePayload.utf8), httpResponse)
		let info = try #require(decoded)

		#expect(info.name == "My Torrent")
		#expect(info.infoHash == "729eb67fe32b4b502f788f992ef07d3f22945a9e")
		#expect(info.files.count == 1)

		guard case let .directory(rootName, rootItems) = info.files.first else {
			Issue.record("Expected a root directory, got \(String(describing: info.files.first))")
			return
		}
		#expect(rootName == "My Torrent")
		#expect(rootItems.count == 2)

		let file = try #require(firstFile(in: rootItems))
		#expect(file.name == "data.bin")
		#expect(file.index == 1)
		#expect(file.size == 200)

		let subdirectory = try #require(firstDirectory(in: rootItems))
		#expect(subdirectory.name == "docs")
		let nestedFile = try #require(firstFile(in: subdirectory.items))
		#expect(nestedFile.name == "readme.txt")
		#expect(nestedFile.index == 0)
		#expect(nestedFile.size == 100)
	}

	private func firstFile(in items: [TorrentFileTreeItem]) -> TorrentFileTreeFile? {
		for item in items {
			if case let .file(file) = item {
				return file
			}
		}
		return nil
	}

	private func firstDirectory(in items: [TorrentFileTreeItem]) -> (name: String, items: [TorrentFileTreeItem])? {
		for item in items {
			if case let .directory(name, children) = item {
				return (name, children)
			}
		}
		return nil
	}
}
