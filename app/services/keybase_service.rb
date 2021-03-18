class KeyBaseService

  include AgentLogic

  def initialize
    @keybase_url = "https://keybase.io/"
  end

  def get_validator_avatar(validator)
    image_css = '.picture > .img-circle'
    keybase_url = @keybase_url + validator.keybase_id
    keybase = get_page(url: keybase_url)

    if keybase[:http_code] == '200'

      if Nokogiri::HTML(keybase[:html]).css(image_css).present?
        avatar_url = Nokogiri::HTML(keybase[:html]).css(image_css)
                            .attribute('src').value
        if avatar_url.to_s.include?('keybase_processed_uploads')
          puts "update #{validator.name} avatar to #{avatar_url}"
          validator.update(avatar_url: avatar_url)
        end
      end
    end
  end

end