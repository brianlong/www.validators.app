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
