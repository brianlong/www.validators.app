# frozen_string_literal: true

require "test_helper"

module Blockchain
  module AlpenglowEpochStats
    class CertificateIndexTest < ActiveSupport::TestCase
      def footer(slot, processed: false, **certificates)
        Blockchain::AlpenglowCommunityBlockFooter.create!(slot_number: slot, epoch: 1, processed: processed, **certificates)
      end

      test "#call returns first footer for each certificate slot" do
        first = footer(100, final_cert_slot: 99, notar_reward_slot: 92)
        footer(101, final_cert_slot: 99, notar_reward_slot: 93, skip_reward_slot: 93)

        result = CertificateIndex.new(
          footer_class: Blockchain::AlpenglowCommunityBlockFooter,
          footers: Blockchain::AlpenglowCommunityBlockFooter.order(:slot_number).to_a
        ).call

        assert_equal({ 99 => first }, result[:final])
        assert_equal [92, 93], result[:notar_reward].keys
        assert_equal [93], result[:skip_reward].keys
      end

      test "#call skips certificates already seen in footers before the batch" do
        footer(100, processed: true, final_cert_slot: 99, skip_reward_slot: 90)
        footer(101, final_cert_slot: 99, skip_reward_slot: 91)

        result = CertificateIndex.new(
          footer_class: Blockchain::AlpenglowCommunityBlockFooter,
          footers: Blockchain::AlpenglowCommunityBlockFooter.where(processed: false).to_a
        ).call

        assert_empty result[:final]
        assert_equal [91], result[:skip_reward].keys
      end
    end
  end
end
