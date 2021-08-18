# frozen_string_literal: true

require File.expand_path('../config/environment', __dir__)

include AsnLogic

payload = {
  network: 'testnet'
}

p = Pipeline.new(200, payload)
            .then(&gather_asns)

puts p.inspect
