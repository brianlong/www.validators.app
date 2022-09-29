module IpableConcern
  extend ActiveSupport::Concern

  included do
    has_one :ipable, as: :ipable
    has_one :validator_ip, through: :ipable
  end
end