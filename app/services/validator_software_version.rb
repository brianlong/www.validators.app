class ValidatorSoftwareVersion < ::Gem::Version
  def initialize(number:, network: 'mainnet', best_version: nil)
    super(number)

    @current_version_number = best_version ? best_version : CLUSTER_VERSION[network]
  end

  def running_latest_or_newer?
    self >= current_major_minor_patch
  end

  def running_latest_major_and_minor_or_newer?
    self >= current_major_minor
  end

  def running_latest_major_and_minor_and_patch?
    self == current_major_minor_patch
  end

  def current_major_minor_patch
    Gem::Version.new(@current_version_number)
  end

  def current_major_minor
    current_major_minor_version = @current_version_number.split('.').first(2).join('.')
    Gem::Version.new(current_major_minor_version)
  end

  def self.valid_software_version?(number)
    Gem::Version.correct? number
  end

  def self.software_version_client(version)
    version_arr = version.split('.').map(&:to_i)
    if version_arr.count == 3 && version_arr[1] >= 100 && version_arr[2] > 100
      "Firedancer"
    else
      "Agave"
    end
  end
end
