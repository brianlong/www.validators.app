# frozen_string_literal: true

class Gem::Version
  def self.new(version) # :nodoc:
    return super(**version) unless Gem::Version == self

    @@all[version] ||= super
  end
end
