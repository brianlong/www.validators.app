class PingThingsController < ApplicationController
  def index
    @ping_things = PingThing.where(network: params[:network])
                            .order(created_at: :desc)
                            .last(60)
  end
end