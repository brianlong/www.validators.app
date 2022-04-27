module ObjectCopier
  extend ActiveSupport::Concern

  included do
    after_create :copy_to_second_db

    def copy_to_second_db
      attrs = attributes.except(:id)
      ActiveRecord::Base.connected_to(role: :staging) do
        puts "copying #{self.class.to_s}"
        cp = self.class.create(attrs)
        puts cp.errors.full_messages
      end
    end
  end
end
