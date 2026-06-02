# frozen_string_literal: true

require File.expand_path('../../config/environment', __dir__)

sp = StakePool.find_by!(name: "Aero", network: "mainnet")

sp.update!(
  name: "Phase",
  ticker: "pdsol"
)

puts "StakePool renamed: Aero -> Phase (id: #{sp.id})"
