/// An item contained in a torrent. This could be a file or a directory that contains more items.
public enum TorrentItem: Equatable, Decodable, Sendable {
	/// A file item.
	case file(TorrentFile)
	/// A directory item that can contain more items.
	case directory(name: String, items: [TorrentItem])
}

struct TorrentTree: Decodable, Sendable {
	enum CodingKeys: CodingKey {
		case contents
	}

	let contents: [String: TreeItem]

	func toItems() -> [TorrentItem] {
		contents
			.map {
				$0.value.toTorrentItem(named: $0.key)
			}
	}

	init(from decoder: any Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		contents = try container.decode([String: TreeItem].self, forKey: .contents)
	}

	enum TreeItem: Decodable {
		case file(File)
		case directory(Directory)

		func toTorrentItem(named name: String) -> TorrentItem {
			switch self {
			case let .file(file):
				return .file(.init(name: name, file: file))
			case let .directory(directory):
				return .directory(name: name, items: directory.contents.map { $0.value.toTorrentItem(named: $0.key) })
			}
		}

		private enum TypeCodingKeys: String, CodingKey {
			case type
		}

		init(from decoder: Decoder) throws {
			let container = try decoder.container(keyedBy: TypeCodingKeys.self)
			let type = try container.decode(String.self, forKey: .type)

			switch type {
			case "dir":
				self = try .directory(Directory(from: decoder))
			default:
				self = try .file(File(from: decoder))
			}
		}
	}

	struct File: Decodable, Sendable {
		let index: Int
		let path: String
		let size: Int64
		let progress: Float
		let priority: Priority
	}

	// Directory nodes carry aggregate keys alongside `contents` (`type`, `path`, `size`, `progress`,
	// `progresses`, `priority`), so only `contents` is decoded here — decoding the whole node as a
	// dictionary of children would fail on those extra keys.
	struct Directory: Decodable, Sendable {
		let contents: [String: TreeItem]

		enum CodingKeys: CodingKey {
			case contents
		}
	}
}

private extension TorrentFile {
	init(name: String, file: TorrentTree.File) {
		self = .init(
			index: file.index,
			name: name,
			path: file.path,
			size: file.size,
			progress: file.progress,
			priority: file.priority
		)
	}
}
