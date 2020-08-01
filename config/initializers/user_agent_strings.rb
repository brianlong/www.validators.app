require 'yaml'
USER_AGENT_STRINGS = YAML.load(File.read("#{Rails.root}/config/user_agent_strings.yml"))
