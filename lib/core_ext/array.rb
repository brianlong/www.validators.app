# frozen_string_literal: true

# Array class extensions
class Array
  def median
    idx = size / 2
    sort[idx]
  end

  def average
    guard_numbers
    return nil if empty?
    return nil if sum.nil?

    sum / size.to_f
  end

  private

  def guard_numbers
    return if all? do |el|
      el.is_a? Numeric
    end

    raise ArgumentError, 'Works only for Floats, Decimals and Integers'
  end
end
