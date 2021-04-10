# frozen_string_literal: true

require File.expand_path('../config/environment', __dir__)

network = 'mainnet'

# Expression #2 of SELECT list is not in GROUP BY clause and contains nonaggregated column
# 'validators_staging.vote_account_histories.id' which is not functionally dependent on
# columns in GROUP BY clause; this is incompatible with sql_mode=only_full_group_by (ActiveRecord::StatementInvalid)

random_validator_ids = (1..500).map { |_| Validator.all.sample.id }

sql = <<-SQL_END
  SELECT vote_accounts.validator_id, vote_account_histories.*
  FROM vote_account_histories
  JOIN vote_accounts ON vote_account_histories.vote_account_id = vote_accounts.id
  WHERE vote_account_histories.network = '#{network}'
  AND vote_accounts.validator_id IN (#{random_validator_ids.join(',')})
  GROUP BY vote_accounts.validator_id
  ORDER BY vote_account_histories.id DESC LIMIT 1
SQL_END

p 'executing raw query for all validators'

vote_account_histories = ActiveRecord::Base.connection.execute(sql).to_a

p 'query for all validators finished'

# Validator.find_each do |validator|
#   old_vah = validator&.vote_accounts.where(network: network)&.last&.vote_account_histories&.last

#   new_vah = vote_account_histories.select do |vah_array|
#     vah_array.first == validator.id
#   end.last

#   p "old_software_version: #{old_vah.software_version}"
#   p "new_software_version: #{new_vah}"

#   # if old_vah.software_version
# end
