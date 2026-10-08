# frozen_string_literal: true

require "test_helper"

module Blockchain
  class AlpenglowUserAgentTest < ActiveSupport::TestCase
    AGAVE = "agave/4.4.0-beta.0 (src:c2e16837; feat:6e955f07, client:JitoLabs)"
    RANDOM = "WXYgNix5OCs8eT42Nj14dmZbVRaFAhEhIuogB6AdoJyUvuQ1FiEbFKN/+aZyqP99lmubY5neWph84TDCIur9l9Gid1wMHzWInoafysdmQJTpJ"

    test ".client returns the reported client" do
      assert_equal "JitoLabs", Blockchain::AlpenglowUserAgent.client(AGAVE)
    end

    test ".client falls back to the software name" do
      assert_equal "firedancer", Blockchain::AlpenglowUserAgent.client("firedancer/0.9.1")
      assert_equal "mithril", Blockchain::AlpenglowUserAgent.client("mithril")
    end

    test ".client returns Unknown for unrecognized user agents" do
      assert_equal "Unknown", Blockchain::AlpenglowUserAgent.client(RANDOM)
      assert_equal "Unknown", Blockchain::AlpenglowUserAgent.client("abc/+def")
    end

    test ".client returns Not reported for blank user agents" do
      assert_equal "Not reported", Blockchain::AlpenglowUserAgent.client(nil)
      assert_equal "Not reported", Blockchain::AlpenglowUserAgent.client("")
    end

    test ".version returns the version only for name/version user agents" do
      assert_equal "4.4.0-beta.0", Blockchain::AlpenglowUserAgent.version(AGAVE)
      assert_nil Blockchain::AlpenglowUserAgent.version(RANDOM)
      assert_nil Blockchain::AlpenglowUserAgent.version("mithril")
      assert_nil Blockchain::AlpenglowUserAgent.version(nil)
    end
  end
end
