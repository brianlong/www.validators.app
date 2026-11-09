# frozen_string_literal: true

module XNotifications
  module Formatting
    LAMPORTS_PER_SOL = 1_000_000_000
    VALIDATOR_NAME_MAX_LENGTH = 40

    def validator_label(validator)
      return validator.name.truncate(VALIDATOR_NAME_MAX_LENGTH, omission: "…") if validator.name.present?

      "#{validator.account.first(4)}…#{validator.account.last(4)}"
    end

    def format_sol(lamports)
      sol = lamports.to_f / LAMPORTS_PER_SOL

      return "#{(sol / 1_000_000).round(1)}M" if sol >= 1_000_000
      return "#{(sol / 1_000).round(1)}K" if sol >= 1_000

      sol.round.to_s
    end

    def format_duration(seconds)
      minutes = (seconds / 60).floor

      return "#{minutes} minutes" if minutes < 60

      "#{minutes / 60}h #{minutes % 60}m"
    end

    def format_commission(value)
      "#{value.to_f.round(2).to_s.delete_suffix('.0')}%"
    end

    def join_within_limit(prefix, items, suffix = "", separator: ", ")
      text = prefix.dup
      items.each_with_index do |item, index|
        rest = items.size - index - 1
        more = rest.positive? ? " and #{rest} more" : ""
        candidate = "#{text}#{index.zero? ? '' : separator}#{item}"

        if "#{candidate}#{more}#{suffix}".length > X_POST_MAX_LENGTH
          return "#{text} and #{items.size - index} more#{suffix}"
        end

        text = candidate
      end

      "#{text}#{suffix}"
    end
  end
end
