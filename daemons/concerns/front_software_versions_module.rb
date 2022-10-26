# frozen_string_literal: true

require_relative './front_stats_constants.rb'

module FrontSoftwareVersionsModule
  include FrontStatsConstants

  def get_latest_versions_report(network)
    @report ||= Report.where(
      name: FrontStatsConstants::SOFTWARE_VERSION_REPORT_NAME,
      network: network).order(created_at: :desc).first

    @report&.payload
  end

  def get_versions_for_networks(networks = FrontStatsConstants::NETWORKS)
    res = {}
    networks.each do |network|
      res[network] = get_latest_versions_report(network)
    end
    res
  end

  def broadcast_software_versions(software_versions)
    ActionCable.server.broadcast("software_versions_channel", software_versions)
  end
end
