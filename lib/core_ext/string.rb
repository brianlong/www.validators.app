# frozen_string_literal: true

# String class extensions
class String
  def encode_utf_8
    encode('UTF-8', invalid: :replace, undef: :replace, replace: '')
  end
end
