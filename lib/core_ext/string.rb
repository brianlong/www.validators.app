# frozen_string_literal: true

# String class extensions
class String
  def encode_utf_8
    encode('UTF-8', invalid: :replace, undef: :replace, replace: '')
  end

  def to_hex
    each_byte.map{ |c| "#{c.to_i.to_s(16)}"}.join('\x')
  end
end
