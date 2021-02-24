class ValidatorSoftwareVersion < ::Gem::Version
  # the app needs to get reloaded if cluster.yml changes
  CURRENT_VERSION = YAML.load(File.read('config/cluster.yml'))['software_patch_mainnet']

  def running_latest_or_edge?
    self >= Gem::Version.new(CURRENT_VERSION)
  end

  def running_latest_minor?
    current_major_minor_version = CURRENT_VERSION.split('.').first(2).join('.')
    self >= Gem::Version.new(current_major_minor_version)
  end
end
