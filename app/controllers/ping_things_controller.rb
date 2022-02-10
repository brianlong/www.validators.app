# frozen_string_literal: true

class PingThingsController < ApplicationController
  def index
    @ping_things = PingThing.where(network: params[:network])
                            .includes(:user)
                            .order(created_at: :desc)
                            .first(240)
    @ping_things_count = @ping_things.count
    @ping_things_array_for_chart = @ping_things.pluck(:response_time).reverse
  end
end
