# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

def create_users
  @admin = User.find_or_initialize_by(
    username: 'adminuser',
    is_admin: true
  ) do |admin|
    admin.email = 'adminuser@example.com'
    admin.password = 'Password1'
    admin.password_confirmation = 'Password1'
  end

  @admin.save
  @admin.confirm

  @user = User.find_or_initialize_by(
    username: 'testuser',
    is_admin: false
  ) do |user|
    user.email = 'test.user@example.com'
    user.password = 'Password1'
    user.password_confirmation = 'Password1'
  end

  @user.save
  @user.confirm
end

def create_data_centers
  DataCenter.find_or_create_by(
    traits_autonomous_system_number: 0,
    city_name: "Unknown"
  )
end

if Rails.env.development?
  # User.destroy_all # uncomment to destroy users, regenerate api_tokens etc.

  create_users
  puts "user and admin created"

  load(Rails.root.join('script', 'add_current_epoch.rb') )
  puts "added current epochs"

  puts %{
    For further population of the database check scripts located in /daemons and /script.
    Note that more specific instructions are held in /dev/instruction.md file.
  }

  create_data_centers
end
