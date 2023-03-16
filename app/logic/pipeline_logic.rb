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

def array_average(array)
  return nil unless array.is_a? Array
  return nil if array.compact!.empty?
  return nil if array.sum.zero?

  array.sum.to_i / array.size.to_f
end

def array_median(array)
  return nil unless array.is_a? Array
  return nil if array.empty?

  sorted = array.sort
  mid = (sorted.length - 1) / 2.0
  (sorted[mid.floor] + sorted[mid.ceil]) / 2.0
end

# Monkey patch the .median method
class ActiveRecord::Base
  def self.median(column_name)
    # pluck out the given column, order it and take out the value exactly halfway
    # reduce the mysql queries
    arry = pluck(column_name)
    median_index = arry.size / 2
    arry.sort[median_index]
  end
end
