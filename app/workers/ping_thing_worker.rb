class PingThingWorker
  include Sidekiq::Worker

  def perform(args = {})
    PingThingRaw.first(100).each do |raw|
      params = raw.attributes_from_raw
      user = User.find_by(api_token: raw.api_token)
      PingThing.create(params.merge(user: user, token: raw.token))
      raw.delete
    end
  end
end
