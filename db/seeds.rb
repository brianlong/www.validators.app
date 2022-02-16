# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

@networks = %w(mainnet testnet)

def create_users
  @admin = User.find_or_initialize_by(
    username: 'brianlong',
    is_admin: true
  ) do |admin|
    admin.email = 'brian.long@fmaprivacy.com'
    admin.password = 'Password1'
    admin.password_confirmation = 'Password1'
  end

  @admin.save
  @admin.confirm

  @user = User.find_or_initialize_by(
    username: 'testuser',
    is_admin: false
  ) do |user|
    user.email = 'test.user@fmaprivacy.com'
    user.password = 'Password1'
    user.password_confirmation = 'Password1'
  end

  @user.save
end

def create_ping_things(number)
  apps = ['application1', 'application2', 'application3']

  number.times do 
    PingThing.create(
      amount: 1, 
      application: apps.sample,
      network: @networks.sample, 
      response_time: rand(200..400),
      signature: SecureRandom.hex(32), 
      success: true,
      transaction_type: 'transfer', 
      user_id: @admin.id
    ) 
  end
end

if Rails.env.development?
  PingThing.destroy_all
  # User.destroy_all # uncomment to destroy users, regenerate api_tokens etc.

  create_users
  create_ping_things(240)
end