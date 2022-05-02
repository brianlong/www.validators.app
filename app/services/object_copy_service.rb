# frozen_string_literal: true

class ObjectCopyService

  def initialize(original: , database_role: :staging)
    @original = original
    @database_role = database_role
  end

  def call
    new_copy = @original.dup
    new_copy.skip_copy = true # prevent infinite loop on after_create
    use_custom_db do
      unless new_copy.save
        new_copy = add_associated_records(new_copy)
        new_copy.save
      end
    end
  end

  def add_associated_records(new_copy)
    @original.class.reflect_on_all_associations(:belongs_to).map{|x| x.name}.compact.each do |assoc|
      associated_attrs = @original.send(assoc.to_s).attributes.except(:id, :created_at, :updated_at)
      if assoc == :user
        new_user = User.find_or_create_by(username: associated_attrs["username"]) do |user|
          user.password = SecureRandom.hex(6)
          user.email ||= "#{SecureRandom.hex(3)}@example.com"
        end
        puts new_user.errors.messages
        new_copy.user = new_user
      end
    end
    new_copy
  end

  def use_custom_db &block
    ActiveRecord::Base.connected_to(role: @database_role) do
      yield
    end
  end
end
