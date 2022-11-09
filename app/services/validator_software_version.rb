class ValidatorSoftwareVersion < ::Gem::Version
  def initialize(number:, network: 'mainnet', best_version: nil)
    super(number)
    if best_version
      @current_version_number = best_version
    else
      @current_version_number =
        case network
        when "mainnet" then MAINNET_CLUSTER_VERSION
        when "testnet" then TESTNET_CLUSTER_VERSION
        when "pythnet" then PYTHNET_CLUSTER_VERSION
        end
    end
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
end
