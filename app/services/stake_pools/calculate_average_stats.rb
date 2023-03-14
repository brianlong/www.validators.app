# frozen_string_literal: true

module StakePools
  class CalculateAverageStats
    def initialize(pool)
      @pool = pool
    end

    def call
      @sp_attrs = initial_attrs

      Validator.where(id: validator_ids)
               .includes(:stake_accounts, :validator_score_v1)
               .find_each do |validator|
        @validator = validator
        score = validator.score
        validator_active_stake = calculate_active_stake

        sp_attrs[:total_active_stake] += validator_active_stake
        sp_attrs[:uptimes].push uptime
        sp_attrs[:lifetimes].push lifetime
        sp_attrs[:scores].push validator_active_stake * score.total_score.to_i
        sp_attrs[:last_skipped_slots].push score.skipped_slot_history&.last
        sp_attrs[:commissions].push(validator_active_stake * validator.score.commission)
        sp_attrs[:delinquent_count] =
          score.delinquent ? sp_attrs[:delinquent_count] + 1 : sp_attrs[:delinquent_count]
      end

      set_averages
    end

    private

    attr_reader :pool, :validator, :validator_ids, :sp_attrs

    def calculate_active_stake
      validator.stake_accounts.active.where(stake_pool: pool).sum(:active_stake)
    end

    def validator_ids
      @validator_ids ||= pool.stake_accounts.active.pluck(:validator_id)
    end

    def uptime
      (DateTime.now - last_delinquent.to_datetime).to_i
    end

    def lifetime
      (DateTime.now - validator.created_at.to_datetime).to_i
    end

    def average_commission
      (sp_attrs[:commissions].sum / sp_attrs[:total_active_stake].to_f).round(2)
    end

    def last_delinquent
      validator.validator_histories
               .order(created_at: :desc)
               .where(delinquent: true)
               .first
               &.created_at || (DateTime.now - 30.days)
    end

    def set_averages
      pool.average_validators_commission = average_commission
      pool.average_uptime = sp_attrs[:uptimes].average
      pool.average_lifetime = sp_attrs[:lifetimes].average
      pool.average_score = (sp_attrs[:scores].sum / sp_attrs[:total_active_stake].to_f).round(2)
      pool.average_delinquent = (sp_attrs[:delinquent_count] / validator_ids.size) * 100
      pool.average_skipped_slots = sp_attrs[:last_skipped_slots].compact.average
    end

    def initial_attrs
      {
        total_active_stake: 0,
        commissions: [],
        delinquent_count: 0,
        last_skipped_slots: [],
        uptimes: [],
        lifetimes: [],
        scores: []
      }
    end
  end
end
