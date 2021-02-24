class ValidatorSoftwareVersion < ::Gem::Version
  def running_latest_or_edge?
    self >= Gem::Version.new(CURRENT_VERSION)
  end

  def running_latest_minor?
    current_major_minor_version = CURRENT_VERSION.split('.').first(2).join('.')
    self >= Gem::Version.new(current_major_minor_version)
  end
end
