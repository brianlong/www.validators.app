module ObjectCopier
  extend ActiveSupport::Concern
  
  included do
    attr_accessor :skip_copy

    after_create :copy_to_stage_db, unless: :skip_copy

    def copy_to_stage_db
      ObjectCopyService.new(original: self).call
    end
  end
end
