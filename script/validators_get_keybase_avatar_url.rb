# frozen_string_literal: true

# RAILS_ENV=production bundle exec ruby script/validators_get_keybase_avatar_url.rb
require File.expand_path('../config/environment', __dir__)

include AgentLogic

interrupted = false
trap('INT') { interrupted = true }  unless Rails.env.test?

# .picture > img:nth-child(1)
image_css = '.picture > .img-circle'

NETWORKS.each do |network|
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
        end
      end
    end

    # break # for development
    break if interrupted
  rescue StandardError => e
    Appsignal.send_error(e)
    next
  end
end
