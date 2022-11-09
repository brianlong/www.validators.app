cluster_yml = YAML.load(File.read('config/cluster.yml'))
MAINNET_CLUSTER_VERSION = cluster_yml['software_patch_mainnet']
TESTNET_CLUSTER_VERSION = cluster_yml['software_patch_testnet']
PYTHNET_CLUSTER_VERSION = cluster_yml['software_patch_pythnet']

unless MAINNET_CLUSTER_VERSION.split('.').length == 3
  raise 'Invalid value entered for software_patch_mainnet version. Should be specific as x.y.z'
end

unless TESTNET_CLUSTER_VERSION.split('.').length == 3
  raise 'Invalid value entered for software_patch_testnet version. Should be specific as x.y.z'
end

unless PYTHNET_CLUSTER_VERSION.split('.').length == 3
  raise 'Invalid value entered for software_patch_pythnet version. Should be specific as x.y.z'
end
