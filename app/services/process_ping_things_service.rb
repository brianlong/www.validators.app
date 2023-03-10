# frozen_string_literal: true

class ProcessPingThingsService

  def initialize(records_count: 100)
    @records_count = records_count
  end

  def call
    records_to_process.each do |raw|
      params = raw.attributes_from_raw
      user = User.find_by(api_token: raw.api_token)

      params.merge!(
        user: user,
        network: raw.network,
        created_at: raw.created_at
      )
      start_create = Time.now
      PingThing.create(params)
      Rails.logger.warn("ProcessPingThing: create (#{raw.id}): #{Time.now - start_create}s")
      raw.delete

    # in case of passing wrong commitment_level, which is an enum
    # that raises an ArgumentError when wrong value is assigned
    rescue ArgumentError => e
      raw.delete
      next
    end

    true
  end

  private

  def records_to_process
    PingThingRaw.first(@records_count)
  end
end
