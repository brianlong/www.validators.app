# frozen_string_literal: true

module Api
  module V1
    class DataCentersController < BaseController
      def index_with_nodes
        show_gossip_nodes = dc_params[:show_gossip_nodes].in?(["true", nil])

        fields_dc = DataCenter::FIELDS_FOR_GOSSIP_NODES.map do |field|
          "data_centers.#{field}"
        end
        fields_stats = DataCenterStat::FIELDS_FOR_API.map do |field|
          "data_center_stats.#{field}"
        end
        fields_stats.delete("data_center_stats.active_gossip_nodes_count") unless show_gossip_nodes

        merged_fields = (fields_dc + fields_stats).join(", ")

        query = if show_gossip_nodes
                  "data_center_stats.active_gossip_nodes_count > 0
                  OR data_center_stats.active_validators_count > 0"
                else
                  "data_center_stats.active_validators_count > 0"
                end

        data_centers = DataCenter.select(merged_fields)
                                 .joins(:data_center_stats)
                                 .where.not(data_center_key: "0--Unknown")
                                 .where("data_center_stats.network = ?", dc_params[:network])
                                 .where(query)
                                 .order(:active_validators_count)

        data_centers_groups = {}
        data_centers.group_by(&:country_iso_code).each do |country_group|
          # group large countries by regions (subdivisions)
          # United States, Canada, Russia, China, Australia, India
          if country_group.first.in? ["US", "CA", "RU", "CN", "AU", "IN"]
            country_group.last.group_by(&:subdivision_iso_code).each do |subdivision_group|
              identifier = "#{country_group.first}/#{subdivision_group.first}"
              data_centers_groups[identifier] = {
                identifier: identifier,
                active_validators_count: subdivision_group.last.pluck(:active_validators_count).compact.sum,
                active_gossip_nodes_count: subdivision_group.last.pluck(:active_gossip_nodes_count).compact.sum,
                longitude: subdivision_group.last.first.longitude,
                latitude: subdivision_group.last.first.latitude,
                data_centers: subdivision_group.last.pluck(:data_center_key),
              }
            end
          else
            # group the rest by country
            data_centers_groups[country_group.first] = {
              identifier: country_group.first,
              active_validators_count: country_group.last.pluck(:active_validators_count).compact.sum,
              active_gossip_nodes_count: country_group.last.pluck(:active_gossip_nodes_count).compact.sum,
              longitude: country_group.last.first.longitude,
              latitude: country_group.last.first.latitude,
              data_centers: country_group.last.pluck(:data_center_key),
            }
          end
        end

        render json: {
          data_centers_groups: data_centers_groups
        }, status: :ok
      end

      def data_center_stats
        dc_by_country = DataCenterStat.where(network: dc_params[:network])
                                      .joins(:data_center)
                                      .group(:country_name)

        dc_by_organization = DataCenterStat.where(network: dc_params[:network])
                                           .joins(:data_center)
                                           .group(:traits_organization)

        if dc_params[:secondary_sort] == "count"
          dc_by_country = dc_by_country.sum(:active_validators_count)
          dc_by_organization = dc_by_organization.sum(:active_validators_count)
        else
          dc_by_country = dc_by_country.sum(:active_validators_stake)
          dc_by_organization = dc_by_organization.sum(:active_validators_stake)
        end
        dc_by_country = dc_by_country.sort_by { |k, v| v}.reverse
        dc_by_organization = dc_by_organization.sort_by { |k, v| v}.reverse

        render json: {
          dc_by_country: dc_by_country,
          dc_by_organization: dc_by_organization
        }, status: :ok
      end

      private

      def dc_params
        params.permit(:network, :show_gossip_nodes, :secondary_sort)
      end
    end
  end
end
