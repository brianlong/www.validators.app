# frozen_string_literal: true

# RAILS_ENV=production bundle exec ruby script/validators_get_avatar_url.rb
require File.expand_path('../config/environment', __dir__)

# Default URL is at 'https://keybase.io/images/no-photo/placeholder-avatar-180-x-180@2x.png'

include AgentLogic

interrupted = false
trap('INT') { interrupted = true }

# .picture > img:nth-child(1)
image_css = '.picture > .img-circle'

%w[testnet mainnet].each do |network|
  Validator.where(
    ["network = ? and keybase_id != '' AND avatar_url IS NULL", network]
  ).each do |validator|
    keybase_url = "https://keybase.io/#{validator.keybase_id}"
    keybase = get_page(url: keybase_url)

    if keybase[:http_code] == '200'

      if Nokogiri::HTML(keybase[:html]).css(image_css).present?
        avatar_url = Nokogiri::HTML(keybase[:html]).css(image_css)
                             .attribute('src').value

        if avatar_url.to_s.include?('keybase_processed_uploads')
          validator.update(avatar_url: avatar_url)
          puts "URL: #{avatar_url}"
        end
      else
        puts "Image not found #{keybase_url}"
      end
    else
      puts "Non-200 Code: #{keybase[:http_code]}"
    end

    # break # for development
    break if interrupted
  rescue StandardError => e
    AppSignal.send_error(e)
    next
  end
end
