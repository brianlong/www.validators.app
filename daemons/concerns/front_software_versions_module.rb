# frozen_string_literal: true

require_relative './front_stats_constants.rb'

module FrontSoftwareVersionsModule
  include FrontStatsConstants
  include ValidatorsHelper

  def get_versions_for_networks
    versions_for_networks = {}
    ::NETWORKS.each do |network|
      versions_for_networks[network] = sort_software_versions(get_latest_versions_report(network))
    end
    versions_for_networks
  end

  def broadcast_software_versions(software_versions)
    ActionCable.server.broadcast("software_versions_channel", software_versions)
  end

  private

  def get_latest_versions_report(network)
    @report ||= {}
    @report[network] ||= Report.where(
      name: FrontStatsConstants::SOFTWARE_VERSION_REPORT_NAME,
      network: network
    ).order(created_at: :desc).first

    @report[network]&.payload
  end
end
