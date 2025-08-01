class SolanaCliService
  def self.app_path
    if Rails.env.production?
      '/var/www/validators_p/current'
    elsif Rails.env.stage? || Rails.env.staging?
      '/var/www/validators_s/current'
    else
      ''
    end
  end

  def self.request(cli_method, rpc_url)
    `cd #{app_path}; solana #{cli_method} --output json-compact --url #{rpc_url}`
  end

  def self.request_with_params(cli_method, rpc_url, params)
    `cd #{app_path}; solana #{cli_method} --output json-compact --url #{rpc_url} #{params}`
  end
end
