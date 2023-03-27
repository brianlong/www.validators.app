# frozen_string_literal: true

class SoftwareVersionsChannel < ApplicationCable::Channel
  def subscribed
    stream_from "software_versions_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
