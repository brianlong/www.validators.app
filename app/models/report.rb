# frozen_string_literal: true

# The Report model will hold pre-compiled reports

# == Schema Information
#
# Table name: reports
#
#  id         :bigint           not null, primary key
#  batch_uuid :string(191)
#  name       :string(191)
#  network    :string(191)
#  payload    :text(4294967295)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_reports_on_network_and_batch_uuid           (network,batch_uuid)
#  index_reports_on_network_and_name_and_created_at  (network,name,created_at)
#
class Report < ApplicationRecord
  serialize :payload, JSON
end
