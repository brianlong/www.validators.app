# frozen_string_literal: true

require File.expand_path('../../config/environment', __dir__)

VoteAccount.joins(:account_authority_histories)
           .includes(:account_authority_histories)
           .find_each do |va|
  invalid_voters = va.account_authority_histories.select do |history|
    if history.authorized_withdrawer_after == history.authorized_withdrawer_before
      before_values = Array(history.authorized_voters_before&.values)
      after_values = Array(history.authorized_voters_after&.values)

      before_values.size == (before_values & after_values).size
    end
  end

  AccountAuthorityHistory.where(id: invalid_voters).destroy_all

  history_last = va.account_authority_histories.last

  if va.authorized_voters != history_last.authorized_voters_after
    va.update_column(:authorized_voters, history_last.authorized_voters_after)
  end
end
