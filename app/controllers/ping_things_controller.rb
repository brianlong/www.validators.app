#frozen_string_literal: true

class PingThingsController < ApplicationController
  def index
    @ping_things = PingThing.where(network: params[:network])
                            .includes(:user)
                            .order(created_at: :desc)
                            .first(240)
  end
end
