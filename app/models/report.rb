# frozen_string_literal: true

# == Schema Information
#
# Table name: reports
#
#  id         :bigint           not null, primary key
#  network    :string(255)
#  name       :string(255)
#  payload    :text(4294967295)
#  batch_uuid :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# The Report model will hold pre-compiled reports
class Report < ApplicationRecord
  serialize :payload, JSON
end
