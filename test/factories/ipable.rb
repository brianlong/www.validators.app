# frozen_string_literal: true

FactoryBot.define do
    factory :ipable do
        validator_ip_id { create(:validator_id)}
        ipable_type
        ipable_id
    end
  end
  