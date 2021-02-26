class ValidatorSoftwareVersion < ::Gem::Version
  def initialize(number:, network: 'mainnet')
    super(number)
    @current_version_number = network == 'mainnet' ? MAINNET_CLUSTER_VERSION : TESTNET_CLUSTER_VERSION
  end

  def running_latest_or_newer?
    self >= current_major_minor_patch
  end

  def running_latest_major_and_minor?
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
end
