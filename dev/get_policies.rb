require File.expand_path('../config/environment', __dir__)
require 'borsh'

include SolanaRequestsLogic

program_id = {
  mainnet: "b1ockYL7X6sGtJzueDbxRVBEEPN4YeqoLW276R3MX8W"
}
encoding = "jsonParsed"

NETWORKS.each do |network|
  next unless program_id[network.to_sym]

  network = network
  config_urls = Rails.application.credentials.solana["#{network}_urls".to_sym]

  results = solana_client_request(
    config_urls,
    :get_program_accounts,
    params: [program_id[network.to_sym], { encoding: encoding }]
  )

  results.each do |result|
    result = result["account"]["data"][0]

    raw_data = Base64.decode64(result)
    identities_len_bytes = raw_data[3..6]  # bytes 3-6 (0-indexed)
    identities_len = identities_len_bytes.unpack1("L<")

    puts "Identities count: #{identities_len}"

    # calculate exact byte range for identities (start at byte 7)
    identities_end = 7 + (identities_len * 32) - 1

    # get only the bytes we need
    raw_identities = raw_data[7..identities_end]

    # extract each 32-byte pubkey and convert to base58
    identities = []
    (0...identities_len).each do |i|
      start = i * 32
      pubkey_bytes = raw_identities[start...(start + 32)]
      pubkey_base58 = Base58.binary_to_base58(pubkey_bytes)
      identities << pubkey_base58
    end
    puts identities.inspect

    puts "Total validators: #{Validator.where(account: identities, network: network).count}"
  end
end
