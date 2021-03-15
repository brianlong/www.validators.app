cluster_yml = YAML.load(File.read('config/cluster.yml'))
MAINNET_CLUSTER_VERSION = cluster_yml['software_patch_mainnet']
MAINNET_CLUSTER_URLS = cluster_yml['mainnet_urls']
TESTNET_CLUSTER_VERSION = cluster_yml['software_patch_testnet']
TESTNET_CLUSTER_URLS = cluster_yml['testnet_urls']

BLOCK_LOGIC_VOTE_ACCOUNT = if Rails.env.production?
  '9GJmEHGom9eWo4np4L5vC6b6ri1Df2xN8KFoWixvD1Bs'
else
  '8zipsAVJU28GyirnyUNwt2yjTNuNusq3ZiJoVn41EgJE'
end

STAKE_BOSS_ADDRESS = if Rails.env.production?
  cluster_yml['stake_boss_mainnet']
else
  cluster_yml['stake_boss_testnet']
end

STAKE_BOSS_MIN = 10 # SOL
STAKE_BOSS_N_SPLIT_OPTIONS = [2,4,8,16,32,64,128,256]

unless MAINNET_CLUSTER_VERSION.split('.').length == 3
  raise 'Invalid value entered for software_patch_mainnet version. Should be specific as x.y.z'
end

unless TESTNET_CLUSTER_VERSION.split('.').length == 3
  raise 'Invalid value entered for software_patch_testnet version. Should be specific as x.y.z'
end
