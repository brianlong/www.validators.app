module ObjectCopier
  extend ActiveSupport::Concern
  
  included do
    attr_accessor :skip_copy

    after_create :copy_to_stage_db, unless: :skip_copy

    def copy_to_stage_db
      if should_copy_records?
        ObjectCopyService.new(original: self).call
      end
    end

    def should_copy_records?
      Rails.env.production? && [true, "true"].include?(Rails.application.credentials.copy_records_to_stage)
    end
  end
end
