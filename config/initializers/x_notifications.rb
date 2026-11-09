# frozen_string_literal: true

X_NOTIFICATIONS = {
  delinquency_started: true,
  delinquency_resolved: true,
  commission_epoch_report: true,
  stake_pool_epoch_report: true
}.freeze

X_NOTIFICATIONS_NETWORKS = %w[mainnet].freeze
X_NOTIFICATIONS_LIVE_ENVIRONMENTS = %w[production].freeze

X_POST_MAX_LENGTH = 280

X_DELINQUENCY_MIN_MINUTES = 15
X_DELINQUENCY_MAX_AGE_HOURS = 24
X_DELINQUENCY_MIN_STAKE_SOL = 100_000

X_COMMISSION_MIN_INCREASE = 10

X_STAKE_POOL_MIN_CHANGE_SOL = 10_000

X_EPOCH_REPORT_DELAY_HOURS = 2
