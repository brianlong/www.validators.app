# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  api_token              :string(191)
#  confirmation_sent_at   :datetime
#  confirmation_token     :string(191)
#  confirmed_at           :datetime
#  current_sign_in_at     :datetime
#  current_sign_in_ip     :string(191)
#  email_encrypted        :string(191)
#  email_encrypted_iv     :string(191)
#  email_hash             :string(191)
#  encrypted_password     :string(191)      not null
#  failed_attempts        :integer          default(0), not null
#  is_admin               :boolean          default(FALSE)
#  last_sign_in_at        :datetime
#  last_sign_in_ip        :string(191)
#  locked_at              :datetime
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string(191)
#  sign_in_count          :integer          default(0), not null
#  unconfirmed_email      :string(191)
#  unlock_token           :string(191)
#  username               :string(191)      not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_api_token             (api_token) UNIQUE
#  index_users_on_confirmation_token    (confirmation_token) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_unlock_token          (unlock_token) UNIQUE
#  index_users_on_username              (username) UNIQUE
#
class User < ApplicationRecord

  CONFIRMATION_TIME = 7.days
  USERNAME_REGEXP = /\A[a-zA-Z0-9.]+\z/.freeze
  EMAIL_REGEXP = /\A(|(([A-Za-z0-9]+_+)|([A-Za-z0-9]+\-+)|([A-Za-z0-9]+\.+)|([A-Za-z0-9]+\++))*[A-Za-z0-9]+@((\w+\-+)|(\w+\.))*\w{1,63}\.[a-zA-Z]{2,15})\z/i.freeze

  before_save :create_email_hash

  # has_secure_token will initialize a new token when the record is created.
  # Regenerate a new user token with `user.regenerate_api_token`
  has_secure_token :api_token

  # Include default devise modules. Others available are:
  # :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :lockable, :timeoutable, :trackable,
         authentication_keys: [:username]

  has_many :user_watchlist_elements, dependent: :delete_all 
  has_many :watched_validators, through: :user_watchlist_elements, source: :validator

  # For attr_encrypted:
  attr_encrypted_options.merge!(
    key: Rails.application.credentials.attribute_key,
    prefix: '',
    suffix: '_encrypted'
  )
  attr_encrypted :email

  # For Vault:
  # attr_accessor :email
  # include Vault::EncryptedModel
  # vault_attribute :email

  validates :username,
            presence: true,
            uniqueness: { case_sensitive: false },
            length: { minimum: 3, maximum: 50 },
            format: { with: USERNAME_REGEXP }

  validates :email,
            presence: true,
            format: { with: EMAIL_REGEXP }

  # validate :email_unique?, on: :create

  def self.search_by_email_hash(email)
    where(email_hash: Digest::SHA256.hexdigest(email)).first
  end

  def create_email_hash
    self.email_hash = Digest::SHA256.hexdigest(email)
  end

  # This method is required from somewhere deep in Rails. I think it will tell
  # ActiveRecord to not save the email attribute. Test are red without this
  # method.
  def will_save_change_to_email?
    false
  end

  def to_builder
    Jbuilder.new do |user|
      user.(self, :username)
    end
  end

  private 
  def email_unique?
    existing_email = User.search_by_email_hash(email)

    return true if existing_email.blank? 

    errors.add(:email, :taken)
    false
  end
end
