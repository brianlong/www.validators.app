# frozen_string_literal: true

class PingThingsController < ApplicationController
  def index
    @ping_things = PingThing.where(network: params[:network])
                            .includes(:user)
                            .order(reported_at: :desc)
                            .first(240)
    @ping_things_count = @ping_things.length
    @ping_things_array_for_chart = @ping_things.pluck(:response_time).reverse

    flash.now[:success] = "<p class='text-center'>If you enjoy The Ping Thing, please delegate to&nbsp;
      <a href='https://www.blocklogic.net/' class='alert-link'>Block Logic</a>
      or toss some SOL into The Ping Thing tip jar:&nbsp;ping6gwBZx1ccMMFyLgkVSupUmujYrFidEXuNRPq989.<br />
      Your contributions keep this website running!</p>"
  end
end
