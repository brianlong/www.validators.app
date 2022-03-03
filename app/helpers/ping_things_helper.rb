# frozen_string_literal: true

module PingThingsHelper
  def link_from_signature signature
    url_base = "https://solanabeach.io/transaction/"
    url_base + signature
  end
end
