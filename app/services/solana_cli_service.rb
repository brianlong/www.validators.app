class SolanaCliService
  def self.solana_path
    if Rails.env.production?
      '/home/deploy/.local/share/solana/install/active_release/bin/'
    else
      ''
    end
  end

  def self.request(cli_method, rpc_url)
    `#{solana_path}solana #{cli_method} --output json-compact --url #{rpc_url}`
  end
end
