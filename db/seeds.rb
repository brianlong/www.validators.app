# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)


def create_users
  @admin = User.create(
    username: 'brianlong',
    email: 'brian.long@fmaprivacy.com',
    is_admin: true,
    password: 'Password1',
    password_confirmation: 'Password1'
  )
  @admin.confirm
end

def create_ping_things
  apps = ['application1', 'application2', 'application3']

  240.times do 
    PingThing.create(
      amount: 1, 
      application: apps.sample,
      network: 'testnet', 
      response_time: rand(200..400),
      signature: "5zxrAiJcBkAHpDtY4d3hf8YVgKjENpjUUEYYYH2cCbRozo8BiyTe6c7WtBqp6Rw2bkz7b5Vxkbi9avR7BV9J1a6s", 
      success: true,
      transaction_type: 'transfer', 
      user_id: @admin.id
    ) 
  end
end

if Rails.env.development?
  PingThing.destroy_all
  User.destroy_all

  create_users
  create_ping_things
end