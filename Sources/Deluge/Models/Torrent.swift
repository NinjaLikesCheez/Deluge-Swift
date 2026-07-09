import Foundation

/// A Deluge torrent.
public struct Torrent: Equatable, Decodable, Sendable {
	/// The number of seconds the torrent has been active (downloading or seeding).
	public let activeTime: TimeInterval?
	/// Whether the torrent is managed automatically by Deluge's queueing system.
	public let autoManaged: Bool?
	/// The number of seconds since the torrent completed downloading.
	public let completedTime: TimeInterval?
	/// The comment embedded in the torrent file.
	public let comment: String?
	/// The name of the client that created the torrent file.
	public let creator: String?
	/// The date the torrent was added to the server.
	public let dateAdded: Date?
	/// The number of copies of each piece available across connected peers.
	public let distributedCopies: Float?
	/// The number of bytes downloaded for the torrent.
	public let downloaded: Int64?
	/// The file path where the torrent data is being downloaded to.
	public let downloadPath: String?
	/// The download rate for the torrent in bytes/s.
	public let downloadRate: Int64?
	/// The estimated number of seconds until the torrent completes downloading.
	public let eta: TimeInterval?
	/// The priority of each file in the torrent.
	public let filePriorities: [Int]?
	/// The number of seconds since the torrent finished (equivalent to `completedTime`).
	public let finishedTime: TimeInterval?
	/// The SHA1 hash for the torrent.
	public let hash: String
	/// Whether the torrent has finished downloading.
	public let isFinished: Bool?
	/// Whether the torrent is private (disables DHT, PEX, and LSD).
	public let isPrivate: Bool?
	/// The label assigned to the torrent. If no label is assigned then the value will be an empty string.
	public let label: String?
	/// The configured maximum download speed for the torrent in KiB/s. A value of `-1` means unlimited.
	public let maxDownloadSpeed: Float?
	/// The configured maximum upload speed for the torrent in KiB/s. A value of `-1` means unlimited.
	public let maxUploadSpeed: Float?
	/// The path torrent data is moved to once the torrent finishes downloading.
	public let moveCompletedPath: String?
	/// The name of the torrent.
	public let name: String?
	/// The number of files contained in the torrent.
	public let numFiles: Int?
	/// The number of peers connected for the torrent.
	public let peers: Int?
	/// The download progress for the torrent as a percentage. This is a value between 0 and 1.
	public let progress: Float?
	/// The queue position of the torrent.
	public let queue: Int?
	/// The upload/download ratio for the torrent.
	public let ratio: Float?
	/// The number of connected seeds for the torrent.
	public let seeds: Int?
	/// The number of seconds the torrent has spent seeding.
	public let seedingTime: TimeInterval?
	/// The size of the torrent contents in bytes.
	public let size: Int64?
	/// The state of the torrent.
	public let state: State?
	/// The number of available peers for the torrent.
	public let totalPeers: Int?
	/// The number of available seeds for the torrent.
	public let totalSeeds: Int?
	/// The URL of the tracker currently in use.
	public let tracker: String?
	/// The host portion of the tracker currently in use.
	public let trackerHost: String?
	/// The status message reported by the tracker currently in use.
	public let trackerStatus: String?
	/// The trackers used by the torrent.
	public let trackers: [Tracker]?
	/// The number of bytes uploaded for the torrent.
	public let uploaded: Int64?
	/// The upload rate for the torrent in bytes/s.
	public let uploadRate: Int64?

	/// Initializes a torrent.
	public init(
		activeTime: TimeInterval? = nil,
		autoManaged: Bool? = nil,
		completedTime: TimeInterval? = nil,
		comment: String? = nil,
		creator: String? = nil,
		dateAdded: Date? = nil,
		distributedCopies: Float? = nil,
		downloaded: Int64? = nil,
		downloadPath: String? = nil,
		downloadRate: Int64? = nil,
		eta: TimeInterval? = nil,
		filePriorities: [Int]? = nil,
		finishedTime: TimeInterval? = nil,
		hash: String,
		isFinished: Bool? = nil,
		isPrivate: Bool? = nil,
		label: String? = nil,
		maxDownloadSpeed: Float? = nil,
		maxUploadSpeed: Float? = nil,
		moveCompletedPath: String? = nil,
		name: String? = nil,
		numFiles: Int? = nil,
		peers: Int? = nil,
		progress: Float? = nil,
		queue: Int? = nil,
		ratio: Float? = nil,
		seeds: Int? = nil,
		seedingTime: TimeInterval? = nil,
		size: Int64? = nil,
		state: Torrent.State? = nil,
		totalPeers: Int? = nil,
		totalSeeds: Int? = nil,
		tracker: String? = nil,
		trackerHost: String? = nil,
		trackerStatus: String? = nil,
		trackers: [Tracker]? = nil,
		uploaded: Int64? = nil,
		uploadRate: Int64? = nil
	) {
		self.activeTime = activeTime
		self.autoManaged = autoManaged
		self.completedTime = completedTime
		self.comment = comment
		self.creator = creator
		self.dateAdded = dateAdded
		self.distributedCopies = distributedCopies
		self.downloaded = downloaded
		self.downloadPath = downloadPath
		self.downloadRate = downloadRate
		self.eta = eta
		self.filePriorities = filePriorities
		self.finishedTime = finishedTime
		self.hash = hash
		self.isFinished = isFinished
		self.isPrivate = isPrivate
		self.label = label
		self.maxDownloadSpeed = maxDownloadSpeed
		self.maxUploadSpeed = maxUploadSpeed
		self.moveCompletedPath = moveCompletedPath
		self.name = name
		self.numFiles = numFiles
		self.peers = peers
		self.progress = progress
		self.queue = queue
		self.ratio = ratio
		self.seeds = seeds
		self.seedingTime = seedingTime
		self.size = size
		self.state = state
		self.totalPeers = totalPeers
		self.totalSeeds = totalSeeds
		self.tracker = tracker
		self.trackerHost = trackerHost
		self.trackerStatus = trackerStatus
		self.trackers = trackers
		self.uploaded = uploaded
		self.uploadRate = uploadRate
	}
}

public extension Torrent {
	/// The state of a torrent.
	enum State: String, Equatable, Decodable, Sendable {
		/// The torrent is downloading.
		case downloading = "Downloading"
		/// The torrent is seeding.
		case seeding = "Seeding"
		/// The torrent is paused.
		case paused = "Paused"
		/// The torrent data is being verified.
		case checking = "Checking"
		/// The torrent is in the queue.
		case queued = "Queued"
		/// The torrent has an error.
		case error = "Error"
	}
}

public extension Torrent {
	/// The keys used to request torrent properties.
	enum PropertyKeys: String, CodingKey, CaseIterable {
		/// Requests the key `active_time` from the API.
		case activeTime = "active_time"
		/// Requests the key `auto_managed` from the API.
		case autoManaged = "auto_managed"
		/// Requests the key `completed_time` from the API.
		case completedTime = "completed_time"
		/// Requests the key `comment` from the API.
		case comment
		/// Requests the key `creator` from the API.
		case creator
		/// Requests the key `time_added` from the API.
		case dateAdded = "time_added"
		/// Requests the key `distributed_copies` from the API.
		case distributedCopies = "distributed_copies"
		/// Requests the key `total_done` from the API.
		case downloaded = "total_done"
		/// Requests the key `download_location` from the API.
		case downloadPath = "download_location"
		/// Requests the key `download_payload_rate` from the API.
		case downloadRate = "download_payload_rate"
		/// Requests the key `eta` from the API.
		case eta
		/// Requests the key `file_priorities` from the API.
		case filePriorities = "file_priorities"
		/// Requests the key `finished_time` from the API.
		case finishedTime = "finished_time"
		/// Requests the key `is_finished` from the API.
		case isFinished = "is_finished"
		/// Requests the key `private` from the API.
		case isPrivate = "private"
		/// Requests the key `label` from the API.
		case label
		/// Requests the key `max_download_speed` from the API.
		case maxDownloadSpeed = "max_download_speed"
		/// Requests the key `max_upload_speed` from the API.
		case maxUploadSpeed = "max_upload_speed"
		/// Requests the key `move_completed_path` from the API.
		case moveCompletedPath = "move_completed_path"
		/// Requests the key `name` from the API.
		case name
		/// Requests the key `num_files` from the API.
		case numFiles = "num_files"
		/// Requests the key `num_peers` from the API.
		case peers = "num_peers"
		/// Requests the key `progress` from the API.
		case progress
		/// Requests the key `queue` from the API.
		case queue
		/// Requests the key `ratio` from the API.
		case ratio
		/// Requests the key `num_seeds` from the API.
		case seeds = "num_seeds"
		/// Requests the key `seeding_time` from the API.
		case seedingTime = "seeding_time"
		/// Requests the key `total_size` from the API.
		case size = "total_size"
		/// Requests the key `state` from the API.
		case state
		/// Requests the key `total_peers` from the API.
		case totalPeers = "total_peers"
		/// Requests the key `total_seeds` from the API.
		case totalSeeds = "total_seeds"
		/// Requests the key `tracker` from the API.
		case tracker
		/// Requests the key `tracker_host` from the API.
		case trackerHost = "tracker_host"
		/// Requests the key `tracker_status` from the API.
		case trackerStatus = "tracker_status"
		/// Requests the key `trackers` from the API.
		case trackers
		/// Requests the key `total_uploaded` from the API.
		case uploaded = "total_uploaded"
		/// Requests the key `upload_payload_rate` from the API.
		case uploadRate = "upload_payload_rate"
	}
}
