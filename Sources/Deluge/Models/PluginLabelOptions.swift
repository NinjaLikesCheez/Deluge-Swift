public extension Plugin.Label {
	/// Per-label options, as returned by `label.get_options`.
	struct Options: Equatable, Decodable, Hashable, Sendable {
		/// Whether the max bandwidth/connection options should be applied to torrents with this label.
		public var applyMax: Bool
		/// The maximum download speed, in KiB/s, applied to torrents with this label. `-1` means unlimited.
		public var maxDownloadSpeed: Double
		/// The maximum upload speed, in KiB/s, applied to torrents with this label. `-1` means unlimited.
		public var maxUploadSpeed: Double
		/// The maximum number of connections applied to torrents with this label. `-1` means unlimited.
		public var maxConnections: Int
		/// The maximum number of upload slots applied to torrents with this label. `-1` means unlimited.
		public var maxUploadSlots: Int
		/// Whether to prioritize the first and last pieces of torrents with this label.
		public var prioritizeFirstLast: Bool
		/// Whether the queue options should be applied to torrents with this label.
		public var applyQueue: Bool
		/// Whether torrents with this label should be auto-managed.
		public var isAutoManaged: Bool
		/// Whether torrents with this label should stop seeding at `stopRatio`.
		public var stopAtRatio: Bool
		/// The seed ratio at which torrents with this label should stop seeding.
		public var stopRatio: Double
		/// Whether torrents with this label should be removed once `stopRatio` is reached.
		public var removeAtRatio: Bool
		/// Whether the move-completed options should be applied to torrents with this label.
		public var applyMoveCompleted: Bool
		/// Whether torrents with this label should be moved once completed.
		public var moveCompleted: Bool
		/// The path torrents with this label should be moved to once completed.
		public var moveCompletedPath: String
		/// Whether torrents should be automatically assigned this label.
		public var autoAdd: Bool
		/// The tracker URLs used to automatically match and assign this label to new torrents.
		public var autoAddTrackers: [String]

		enum CodingKeys: String, CodingKey {
			case applyMax = "apply_max"
			case maxDownloadSpeed = "max_download_speed"
			case maxUploadSpeed = "max_upload_speed"
			case maxConnections = "max_connections"
			case maxUploadSlots = "max_upload_slots"
			case prioritizeFirstLast = "prioritize_first_last"
			case applyQueue = "apply_queue"
			case isAutoManaged = "is_auto_managed"
			case stopAtRatio = "stop_at_ratio"
			case stopRatio = "stop_ratio"
			case removeAtRatio = "remove_at_ratio"
			case applyMoveCompleted = "apply_move_completed"
			case moveCompleted = "move_completed"
			case moveCompletedPath = "move_completed_path"
			case autoAdd = "auto_add"
			case autoAddTrackers = "auto_add_trackers"
		}

		public init(
			applyMax: Bool = false,
			maxDownloadSpeed: Double = -1,
			maxUploadSpeed: Double = -1,
			maxConnections: Int = -1,
			maxUploadSlots: Int = -1,
			prioritizeFirstLast: Bool = false,
			applyQueue: Bool = false,
			isAutoManaged: Bool = false,
			stopAtRatio: Bool = false,
			stopRatio: Double = 2.0,
			removeAtRatio: Bool = false,
			applyMoveCompleted: Bool = false,
			moveCompleted: Bool = false,
			moveCompletedPath: String = "",
			autoAdd: Bool = false,
			autoAddTrackers: [String] = []
		) {
			self.applyMax = applyMax
			self.maxDownloadSpeed = maxDownloadSpeed
			self.maxUploadSpeed = maxUploadSpeed
			self.maxConnections = maxConnections
			self.maxUploadSlots = maxUploadSlots
			self.prioritizeFirstLast = prioritizeFirstLast
			self.applyQueue = applyQueue
			self.isAutoManaged = isAutoManaged
			self.stopAtRatio = stopAtRatio
			self.stopRatio = stopRatio
			self.removeAtRatio = removeAtRatio
			self.applyMoveCompleted = applyMoveCompleted
			self.moveCompleted = moveCompleted
			self.moveCompletedPath = moveCompletedPath
			self.autoAdd = autoAdd
			self.autoAddTrackers = autoAddTrackers
		}
	}
}

extension Plugin.Label.Options {
	/// Converts these options into the dictionary format expected by `label.set_options`.
	var rpcDictionary: [String: Any] {
		[
			CodingKeys.applyMax.stringValue: applyMax,
			CodingKeys.maxDownloadSpeed.stringValue: maxDownloadSpeed,
			CodingKeys.maxUploadSpeed.stringValue: maxUploadSpeed,
			CodingKeys.maxConnections.stringValue: maxConnections,
			CodingKeys.maxUploadSlots.stringValue: maxUploadSlots,
			CodingKeys.prioritizeFirstLast.stringValue: prioritizeFirstLast,
			CodingKeys.applyQueue.stringValue: applyQueue,
			CodingKeys.isAutoManaged.stringValue: isAutoManaged,
			CodingKeys.stopAtRatio.stringValue: stopAtRatio,
			CodingKeys.stopRatio.stringValue: stopRatio,
			CodingKeys.removeAtRatio.stringValue: removeAtRatio,
			CodingKeys.applyMoveCompleted.stringValue: applyMoveCompleted,
			CodingKeys.moveCompleted.stringValue: moveCompleted,
			CodingKeys.moveCompletedPath.stringValue: moveCompletedPath,
			CodingKeys.autoAdd.stringValue: autoAdd,
			CodingKeys.autoAddTrackers.stringValue: autoAddTrackers,
		]
	}
}
