# frozen_string_literal: true

# Array class extensions
class Array
  def median
    idx = size / 2
    sort[idx]
  end

  def average
    guard_numbers
    return nil if array.empty?
    return nil if array.sum.nil?

    sum / size.to_f
  end

  private

  def guard_numbers
    return if all? do |el|
      el.class.in? [Numeric, Integer, BigDecimal, Float]
    end

    raise ArgumentError, 'Works only for Floats, Decimals and Integers'
  end
end
