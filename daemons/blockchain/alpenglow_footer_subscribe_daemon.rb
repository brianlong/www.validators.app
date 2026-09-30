# frozen_string_literal: true

require_relative "../../config/environment"

SLEEP_TIME = 1 # second

rpc_uri = URI(Rails.application.credentials.solana[:alpenglow_community_urls][0])

def signers_summary(cert)
  "#{cert[:ranks].size} signers"
end

def footer_summary(footer)
  parts = ["slot=#{footer[:slot]}", "user_agent=#{footer[:block_user_agent].inspect}"]

  if (final_cert = footer[:block_final_cert])
    parts << "final=#{final_cert[:finalization]}(slot=#{final_cert[:slot]}, #{signers_summary(final_cert[:final_aggregate])})"
  end
  if (notar_reward = footer[:notar_reward_cert])
    parts << "notar_reward=(slot=#{notar_reward[:slot]}, #{signers_summary(notar_reward)})"
  end
  if (skip_reward = footer[:skip_reward_cert])
    parts << "skip_reward=(slot=#{skip_reward[:slot]}, #{signers_summary(skip_reward)})"
  end

  parts.join(" ")
end

loop do
  begin
    Blockchain::AlpenglowFooterSubscribeService.new(
      network: "alpenglow-community",
      grpc_url: "#{rpc_uri.host}:#{rpc_uri.port}",
      token: rpc_uri.path.delete("/")
    ).call do |footer|
      puts footer_summary(footer)
    end
  rescue => e
    puts e
    puts e.backtrace

    sleep(SLEEP_TIME)
    next
  end
end
