# frozen_string_literal: true

module VcrHelper
  def vcr_cassette(namespace, name)
    path = File.join(namespace, name.to_s)
    VCR.use_cassette(path) do
      yield
    end
  end
end
