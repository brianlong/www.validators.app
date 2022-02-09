# frozen_string_literal: true

class PingThingValidationService

  def initialize(records_count: 100)
    @records_count = records_count
  end

  def call
    records_to_process.each do |raw|
      params = raw.attributes_from_raw
      user = User.find_by(api_token: raw.api_token)

      params.merge!(
        user: user,
        token: raw.token,
        network: raw.network,
        created_at: raw.created_at
      )

      PingThing.create params
      raw.delete
    end

    true
  end

  private

  def records_to_process
    @records_to_process ||= PingThingRaw.first(@records_count)
  end
end
