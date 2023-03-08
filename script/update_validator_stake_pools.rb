# frozen_string_literal: true

require File.expand_path('../config/environment', __dir__)

stake_pool_attrs = Validator.includes(stake_accounts: :stake_pool)
                            .select(:id)
                            .map do |v|
  {
    id: v.id,
    stake_pool_list: v.stake_accounts.map { |sa| sa.stake_pool_valid&.name }.compact.uniq
  }
end

Validator.upsert_all(stake_pool_attrs)
