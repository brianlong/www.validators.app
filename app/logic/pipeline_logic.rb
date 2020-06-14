# frozen_string_literal: true

# Methods common to all pipeline operations
module PipelineLogic
  # Log errors into the Rails log
  def log_errors
    lambda do |p|
      unless p[:code] == 200
        Appsignal.send_error(p[:errors])
        Rails.logger.error "PIPELINE ERROR CODE: #{p[:code]} MESSAGE: #{p[:message]} CLASS: #{p[:errors].class}"
      end
      p
    end
  end
end
