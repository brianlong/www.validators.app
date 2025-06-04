# frozen_string_literal: true

class PingThingsController < ApplicationController
  skip_before_action :set_network
  before_action :set_network_for_ping_thing

  def index
    @ping_things = PingThing.where(network: params[:network])
                            .includes(:user)
                            .order(reported_at: :desc)
                            .first(240)
    @ping_things_count = @ping_things.length
    @ping_things_array_for_chart = @ping_things.pluck(:response_time).reverse
  end

  def set_network_for_ping_thing
    return if NETWORKS_FOR_PING_THING.include?(params[:network])

    params[:network] = "mainnet"
  end
end
