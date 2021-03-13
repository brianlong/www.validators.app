# == Schema Information
#
# Table name: contact_requests
#
#  id                         :bigint           not null, primary key
#  name_encrypted             :string(255)
#  email_address_encrypted    :string(255)
#  telephone_encrypted        :string(255)
#  comments_encrypted         :text(65535)
#  name_encrypted_iv          :string(255)
#  email_address_encrypted_iv :string(255)
#  telephone_encrypted_iv     :string(255)
#  comments_encrypted_iv      :string(255)
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#
class ContactRequest < ApplicationRecord
  validates :name, presence: true, length: { maximum: 20 }
  validates :email_address, presence: true,
                            length: { maximum: 50 },
                            format: { with: Devise.email_regexp }
  validates :comments, length: { maximum: 500 }

  # For attr_encrypted:
  attr_encrypted_options.merge!(
    key: Rails.application.credentials.attribute_key,
    prefix: '',
    suffix: '_encrypted')
  attr_encrypted :name
  attr_encrypted :email_address
  attr_encrypted :telephone
  attr_encrypted :comments

  # For Vault:
  # attr_accessor :name, :email_address, :telephone
  # include Vault::EncryptedModel
  # vault_lazy_decrypt!
  # vault_attribute :name
  # vault_attribute :email_address
  # vault_attribute :telephone
  # vault_attribute :comments

  default_scope { order('created_at DESC') }
end
