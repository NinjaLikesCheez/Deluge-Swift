import APIClient

public extension DelugeRequest {
	/// Sets the label for a torrent.
	///
	/// RPC Method: `label.set_torrent`
	///
	/// - Parameters:
	///   - hash: The hash of the torrent whose label should be set.
	///   - label: The name of the label to set.
	static func setLabel(hash: String, label: String) -> DelugeRequest<EmptyResponse> {
		.init(method: "label.set_torrent", args: [hash, label])
	}

	/// Requests the list of existing label IDs.
	///
	/// RPC Method: `label.get_labels`
	///
	/// Result: The list of label IDs.
	static var labels: DelugeRequest<[String]> {
		.init(method: "label.get_labels", args: [])
	}

	/// Creates a new label.
	///
	/// RPC Method: `label.add`
	///
	/// - Parameter labelID: The ID of the label to create. Must only contain lowercase letters, numbers, `_`, `-`,
	///   and `.`.
	static func addLabel(_ labelID: String) -> DelugeRequest<EmptyResponse> {
		.init(method: "label.add", args: [labelID])
	}

	/// Removes a label.
	///
	/// RPC Method: `label.remove`
	///
	/// - Parameter labelID: The ID of the label to remove.
	static func removeLabel(_ labelID: String) -> DelugeRequest<EmptyResponse> {
		.init(method: "label.remove", args: [labelID])
	}

	/// Requests the options for a label.
	///
	/// RPC Method: `label.get_options`
	///
	/// - Parameter labelID: The ID of the label whose options should be requested.
	static func labelOptions(_ labelID: String) -> DelugeRequest<LabelOptions> {
		.init(method: "label.get_options", args: [labelID])
	}

	/// Sets the options for a label.
	///
	/// RPC Method: `label.set_options`
	///
	/// - Parameters:
	///   - labelID: The ID of the label whose options should be set.
	///   - options: The new options for the label.
	static func setLabelOptions(_ labelID: String, options: LabelOptions) -> DelugeRequest<EmptyResponse> {
		.init(method: "label.set_options", args: [labelID, options.rpcDictionary])
	}

	/// Requests the plugin-wide configuration for the Label plugin.
	///
	/// RPC Method: `label.get_config`
	static var labelConfig: DelugeRequest<LabelConfig> {
		.init(method: "label.get_config", args: [])
	}

	/// Sets the plugin-wide configuration for the Label plugin.
	///
	/// RPC Method: `label.set_config`
	///
	/// - Parameter config: The new plugin-wide configuration.
	static func setLabelConfig(_ config: LabelConfig) -> DelugeRequest<EmptyResponse> {
		.init(method: "label.set_config", args: [config.rpcDictionary])
	}
}
