# frozen_string_literal: true

cluster_yml = YAML.load(File.read("config/cluster.yml"))

CLUSTER_VERSION = {
  mainnet: cluster_yml["software_patch_mainnet"],
  testnet: cluster_yml["software_patch_testnet"],
  pythnet: cluster_yml["software_patch_pythnet"]
}.stringify_keys.freeze

CLUSTER_VERSION.each do |network, version|
  unless version.split(".").length == 3
    raise "Invalid value entered for software_patch_#{network} version. Should be specific as x.y.z"
  end
end
