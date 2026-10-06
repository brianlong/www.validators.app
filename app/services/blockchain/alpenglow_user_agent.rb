# frozen_string_literal: true

module Blockchain
  module AlpenglowUserAgent
    NOT_REPORTED = "Not reported"

    module_function

    def client(user_agent)
      return NOT_REPORTED if user_agent.blank?

      user_agent[/client:([^;)\s]+)/, 1] || user_agent[%r{\A[^/\s]+}]
    end

    def version(user_agent)
      user_agent.to_s[%r{\A[^/\s]+/(\S+)}, 1]
    end
  end
end
