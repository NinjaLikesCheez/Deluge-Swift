/// A file or directory entry in the file tree of a torrent that has not yet been added, as returned by
/// `web.get_torrent_info`.
public enum TorrentFileTreeItem: Equatable, Decodable, Sendable {
	/// A file entry.
	case file(TorrentFileTreeFile)
	/// A directory entry containing more items.
	case directory(name: String, items: [TorrentFileTreeItem])
}

/// A file entry in a not-yet-added torrent's file tree.
public struct TorrentFileTreeFile: Equatable, Decodable, Sendable {
	/// The name of the file.
	public let name: String
	/// The index of the file within the torrent.
	public let index: Int
	/// The size of the file in bytes.
	public let size: Int64

	enum CodingKeys: String, CodingKey {
		case index
		case size = "length"
	}

	public init(from decoder: any Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		name = ""
		index = try container.decode(Int.self, forKey: .index)
		size = try container.decode(Int64.self, forKey: .size)
	}

	init(name: String, index: Int, size: Int64) {
		self.name = name
		self.index = index
		self.size = size
	}
}

struct TorrentFileTree: Decodable, Sendable {
	enum CodingKeys: CodingKey {
		case contents
	}

	let contents: [String: TreeItem]

	init(from decoder: any Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		contents = try container.decode([String: TreeItem].self, forKey: .contents)
	}

	func toItems() -> [TorrentFileTreeItem] {
		contents.map { $0.value.toTreeItem(named: $0.key) }
	}

	enum TreeItem: Decodable {
		case file(TorrentFileTreeFile)
		case directory(Directory)

		private enum TypeCodingKeys: String, CodingKey {
			case type
		}

		init(from decoder: any Decoder) throws {
			let container = try decoder.container(keyedBy: TypeCodingKeys.self)
			let type = try container.decode(String.self, forKey: .type)

			switch type {
			case "dir":
				self = try .directory(Directory(from: decoder))
			default:
				self = try .file(TorrentFileTreeFile(from: decoder))
			}
		}

		func toTreeItem(named name: String) -> TorrentFileTreeItem {
			switch self {
			case let .file(file):
				return .file(.init(name: name, index: file.index, size: file.size))
			case let .directory(directory):
				return .directory(name: name, items: directory.contents.map { $0.value.toTreeItem(named: $0.key) })
			}
		}
	}

	struct Directory: Decodable, Sendable {
		let contents: [String: TreeItem]

		enum CodingKeys: CodingKey {
			case contents
		}
	}
}
