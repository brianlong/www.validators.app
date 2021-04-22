class SolanaCliService
  def self.solana_path
    if Rails.env.production?
      '/home/deploy/.local/share/solana/install/active_release/bin/'
    else
      ''
    end
  end

  def self.request(cli_method, rpc_url, full_resp = false)
    resp, err, exit_status = Open3.capture3("#{solana_path}solana #{cli_method} --output json-compact --url #{rpc_url}")
    full_resp ? [resp, err, exit_status] : resp
  end
end
