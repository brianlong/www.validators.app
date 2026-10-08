# frozen_string_literal: true

module Blockchain
  module AlpenglowUserAgent
    NOT_REPORTED = "Not reported"
    UNKNOWN = "Unknown"

    NAME = /[A-Za-z][\w.-]{0,31}/.freeze
    REPORTED_CLIENT = /client:(#{NAME})[;)\s]/.freeze
    NAME_WITH_VERSION = %r{\A(#{NAME})/(\d+\.\d+\S*)}.freeze
    NAME_ONLY = /\A#{NAME}\z/.freeze

    module_function

    def client(user_agent)
      return NOT_REPORTED if user_agent.blank?

      user_agent[REPORTED_CLIENT, 1] || user_agent[NAME_WITH_VERSION, 1] || user_agent[NAME_ONLY] || UNKNOWN
    end

    def version(user_agent)
      user_agent.to_s[NAME_WITH_VERSION, 2]
    end
  end
end
