# frozen_string_literal: true

module ResponseHelper
  def response_to_json(response)
    JSON.parse(response)
  end
end
