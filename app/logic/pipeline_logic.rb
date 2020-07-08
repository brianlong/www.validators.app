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

# Monkey patch the .median method
class ActiveRecord::Base
  def self.median(column_name)
    median_index = (count / 2)
    # order by the given column and pluck out the value exactly halfway
    order(column_name).offset(median_index).limit(1).pluck(column_name)[0]
  end
end
