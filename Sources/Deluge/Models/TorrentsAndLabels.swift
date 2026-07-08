import Foundation

public struct TorrentsAndLabels: Decodable, Sendable {
	public let connected: Bool
	public let torrents: [Torrent]
	public let labels: [Label]

	public enum CodingKeys: CodingKey {
		case connected
		case torrents
		case labels
	}

	public init(from decoder: any Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		let torrentsDictionary = try container.decode([String: UnhashedTorrent].self, forKey: .torrents)

		connected = try container.decode(Bool.self, forKey: .connected)
		torrents = torrentsDictionary.map { .init(hash: $0.key, torrent: $0.value) }
		let tempLabels =
			torrentsDictionary
			.filter { !($0.value.label?.isEmpty ?? true) }
			.compactMap(\.value.label)
			.reduce(into: [String: Int]()) { partialResult, label in
				partialResult[label, default: 0] += 1
			}

		labels = tempLabels.map { .init(name: $0.key, count: $0.value) }
	}
}

/// The status fields for a torrent, keyed the same way regardless of which RPC method produced them.
///
/// Shared by `web.update_ui` (via `TorrentsAndLabels`) and `core.get_torrent_status`/`core.get_torrents_status`,
/// all of which return the same field names but never include the torrent's hash in the payload itself.
struct UnhashedTorrent: Decodable, Sendable {
	let activeTime: TimeInterval?
	let autoManaged: Bool?
	let completedTime: TimeInterval?
	let comment: String?
	let creator: String?
	let dateAdded: Date?
	let distributedCopies: Float?
	let downloaded: Int64?
	let downloadPath: String?
	let downloadRate: Int64?
	let eta: TimeInterval?
	let filePriorities: [Int]?
	let finishedTime: TimeInterval?
	let isFinished: Bool?
	let isPrivate: Bool?
	let label: String?
	let maxDownloadSpeed: Float?
	let maxUploadSpeed: Float?
	let moveCompletedPath: String?
	let name: String?
	let numFiles: Int?
	let peers: Int?
	let progress: Float?
	let queue: Int?
	let ratio: Float?
	let seeds: Int?
	let seedingTime: TimeInterval?
	let size: Int64?
	let state: Torrent.State?
	let totalPeers: Int?
	let totalSeeds: Int?
	let tracker: String?
	let trackerHost: String?
	let trackerStatus: String?
	let trackers: [Tracker]?
	let uploaded: Int64?
	let uploadRate: Int64?

	enum CodingKeys: String, CodingKey {
		case activeTime = "active_time"
		case autoManaged = "auto_managed"
		case completedTime = "completed_time"
		case comment
		case creator
		case dateAdded = "time_added"
		case distributedCopies = "distributed_copies"
		case downloaded = "total_done"
		case downloadPath = "download_location"
		case downloadRate = "download_payload_rate"
		case eta
		case filePriorities = "file_priorities"
		case finishedTime = "finished_time"
		case isFinished = "is_finished"
		case isPrivate = "private"
		case label
		case maxDownloadSpeed = "max_download_speed"
		case maxUploadSpeed = "max_upload_speed"
		case moveCompletedPath = "move_completed_path"
		case name
		case numFiles = "num_files"
		case peers = "num_peers"
		case progress
		case queue
		case ratio
		case seeds = "num_seeds"
		case seedingTime = "seeding_time"
		case size = "total_size"
		case state
		case totalPeers = "total_peers"
		case totalSeeds = "total_seeds"
		case tracker
		case trackerHost = "tracker_host"
		case trackerStatus = "tracker_status"
		case trackers
		case uploaded = "total_uploaded"
		case uploadRate = "upload_payload_rate"
	}

	init(from decoder: any Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)

		let dateAddedTime = try container.decodeIfPresent(Double.self, forKey: .dateAdded)
		if let dateAddedTime {
			dateAdded = Date(timeIntervalSince1970: dateAddedTime)
		} else {
			dateAdded = nil
		}

		activeTime = try container.decodeIfPresent(TimeInterval.self, forKey: .activeTime)
		autoManaged = try container.decodeIfPresent(Bool.self, forKey: .autoManaged)
		completedTime = try container.decodeIfPresent(TimeInterval.self, forKey: .completedTime)
		comment = try container.decodeIfPresent(String.self, forKey: .comment)
		creator = try container.decodeIfPresent(String.self, forKey: .creator)
		distributedCopies = try container.decodeIfPresent(Float.self, forKey: .distributedCopies)
		downloaded = try container.decodeIfPresent(Int64.self, forKey: .downloaded)
		downloadPath = try container.decodeIfPresent(String.self, forKey: .downloadPath)
		downloadRate = try container.decodeIfPresent(Int64.self, forKey: .downloadRate)
		eta = try container.decodeIfPresent(TimeInterval.self, forKey: .eta)
		filePriorities = try container.decodeIfPresent([Int].self, forKey: .filePriorities)
		finishedTime = try container.decodeIfPresent(TimeInterval.self, forKey: .finishedTime)
		isFinished = try container.decodeIfPresent(Bool.self, forKey: .isFinished)
		isPrivate = try container.decodeIfPresent(Bool.self, forKey: .isPrivate)
		label = try container.decodeIfPresent(String.self, forKey: .label)
		maxDownloadSpeed = try container.decodeIfPresent(Float.self, forKey: .maxDownloadSpeed)
		maxUploadSpeed = try container.decodeIfPresent(Float.self, forKey: .maxUploadSpeed)
		moveCompletedPath = try container.decodeIfPresent(String.self, forKey: .moveCompletedPath)
		name = try container.decodeIfPresent(String.self, forKey: .name)
		numFiles = try container.decodeIfPresent(Int.self, forKey: .numFiles)
		peers = try container.decodeIfPresent(Int.self, forKey: .peers)
		if let progressValue = try container.decodeIfPresent(Float.self, forKey: .progress) {
			progress = (progressValue / 100)
		} else {
			progress = nil
		}
		queue = try container.decodeIfPresent(Int.self, forKey: .queue)
		ratio = try container.decodeIfPresent(Float.self, forKey: .ratio)
		seeds = try container.decodeIfPresent(Int.self, forKey: .seeds)
		seedingTime = try container.decodeIfPresent(TimeInterval.self, forKey: .seedingTime)
		size = try container.decodeIfPresent(Int64.self, forKey: .size)
		state = try container.decodeIfPresent(Torrent.State.self, forKey: .state)
		totalPeers = try container.decodeIfPresent(Int.self, forKey: .totalPeers)
		totalSeeds = try container.decodeIfPresent(Int.self, forKey: .totalSeeds)
		tracker = try container.decodeIfPresent(String.self, forKey: .tracker)
		trackerHost = try container.decodeIfPresent(String.self, forKey: .trackerHost)
		trackerStatus = try container.decodeIfPresent(String.self, forKey: .trackerStatus)
		trackers = try container.decodeIfPresent([Tracker].self, forKey: .trackers)
		uploaded = try container.decodeIfPresent(Int64.self, forKey: .uploaded)
		uploadRate = try container.decodeIfPresent(Int64.self, forKey: .uploadRate)
	}
}

extension Torrent {
	init(hash: String, torrent: UnhashedTorrent) {
		self = .init(
			activeTime: torrent.activeTime,
			autoManaged: torrent.autoManaged,
			completedTime: torrent.completedTime,
			comment: torrent.comment,
			creator: torrent.creator,
			dateAdded: torrent.dateAdded,
			distributedCopies: torrent.distributedCopies,
			downloaded: torrent.downloaded,
			downloadPath: torrent.downloadPath,
			downloadRate: torrent.downloadRate,
			eta: torrent.eta,
			filePriorities: torrent.filePriorities,
			finishedTime: torrent.finishedTime,
			hash: hash,
			isFinished: torrent.isFinished,
			isPrivate: torrent.isPrivate,
			label: torrent.label,
			maxDownloadSpeed: torrent.maxDownloadSpeed,
			maxUploadSpeed: torrent.maxUploadSpeed,
			moveCompletedPath: torrent.moveCompletedPath,
			name: torrent.name,
			numFiles: torrent.numFiles,
			peers: torrent.peers,
			progress: torrent.progress,
			queue: torrent.queue,
			ratio: torrent.ratio,
			seeds: torrent.seeds,
			seedingTime: torrent.seedingTime,
			size: torrent.size,
			state: torrent.state,
			totalPeers: torrent.totalPeers,
			totalSeeds: torrent.totalSeeds,
			tracker: torrent.tracker,
			trackerHost: torrent.trackerHost,
			trackerStatus: torrent.trackerStatus,
			trackers: torrent.trackers,
			uploaded: torrent.uploaded,
			uploadRate: torrent.uploadRate
		)
	}
}
