class ValidatorSoftwareVersion < ::Gem::Version
  def initialize(number:, network: 'mainnet')
    super(number)
    @current_version_number = network == 'mainnet' ? MAINNET_CLUSTER_VERSION : TESTNET_CLUSTER_VERSION
  end

  def running_latest_or_edge?
    self >= Gem::Version.new(@current_version_number)
  end

  def running_latest_minor?
    current_major_minor_version = @current_version_number.split('.').first(2).join('.')
    self >= Gem::Version.new(current_major_minor_version)
  end
end
