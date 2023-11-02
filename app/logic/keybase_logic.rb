module KeybaseLogic

  include AgentLogic

  KEYBASE_URL = 'https://keybase.io/'

  def get_validator_avatar(validator_keybase_id)
    image_css = '.picture > .img-circle'

    keybase_validator_page = keybase_page(validator_keybase_id)
    if keybase_validator_page[:http_code] == '200' && Nokogiri::HTML(keybase_validator_page[:html]).css(image_css).present?
      avatar_url = Nokogiri::HTML(keybase_validator_page[:html])
                            .css(image_css)
                            .attribute('src').value
      return avatar_url if avatar_url.to_s.include?('keybase_processed_uploads')
    end
    nil
  end

  private

  def keybase_url(validator_keybase_id)
    KEYBASE_URL + validator_keybase_id
  end

  def keybase_page(validator_keybase_id)
    get_page(url: keybase_url(validator_keybase_id))
  end
end
