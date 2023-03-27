module AgentLogic
  include ProxyLogic

  def get_page(params = {})
    max_tries    = params[:max_retries]  || 3
    timeout_secs = params[:timeout_secs] || 60
    sleep_secs   = params[:sleep_secs]   || 60
    result       = { http_code: '0', html: '', tries: 0, errors: [] }
    proxy = {}

    Mechanize.start do |agent|
      while result[:tries] < max_tries
        begin
          result[:tries] += 1
          agent.user_agent = USER_AGENT_STRINGS.sample # 'Windows Mozilla'
          agent.verify_mode = OpenSSL::SSL::VERIFY_NONE
          agent.agent.http.verify_mode = OpenSSL::SSL::VERIFY_NONE
          agent.read_timeout = timeout_secs # Moved the timeout setting to here.
          agent.request_headers = {
            'Accept' => 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
            'Accept-Language' => 'en-US,en;q=0.5',
            'Cache-Control' => 'no-cache',
            'DNT' => '1'
          }

          # Don't need proxies right now...
          #
          # unless Rails.env.in?(%w[test development])
          #   # params should include :use_alt_proxy or :use_smart_proxy for
          #   # residential IPs.
          #   proxy = get_proxy_host(params)
          #   agent.set_proxy(proxy[:host],
          #                   proxy[:port],
          #                   proxy[:user],
          #                   proxy[:password])
          # end
          # proxy ||= {}
          # proxy_for_log = proxy.reject { |k, _v| k == :password }.inspect
          proxy_for_log = proxy
          # TODO: Include logic to detect when the proxy network is down.
          # Mechanize.log&.info "Proxy: #{proxy_for_log}"

          page = agent.get(params[:url].strip)
          result[:http_code] = page.code
          result[:html] = page.body
          break # while
        rescue Timeout::Error => e
          # Network down? Sleep 60 seconds & try again
          result[:http_code] = '599'
          result[:errors] << e.message + (proxy.present? ? " -- #{proxy[:host]}:#{proxy[:port]}" : '')
          add_error(params[:url], result[:http_code], e, proxy_for_log, result[:tries])
          sleep(sleep_secs) unless Rails.env == 'test'
        rescue Net::HTTPNotFound => e
          result[:http_code] = '404'
          # result[:errors] << e.message
          break # while
        rescue Mechanize::ResponseCodeError => e
          result[:http_code] = e.response_code
          result[:errors] << e.message + (proxy.present? ? " -- #{proxy[:host]}:#{proxy[:port]}" : '')
          if %w[403 407 504 502 503].include?(result[:http_code])
            # These response codes are typical of a forward proxy behaving
            # badly. Try again after sleeping. The request will be distributed
            # to a different forward proxy by the proxy network.
            # add_error(params[:url], result[:http_code], e, proxy_for_log, result[:tries])
            sleep(sleep_secs) unless Rails.env == 'test'
          elsif ['404'].include?(result[:http_code])
            # We don't need to log these codes. Do not retry
            break # Stop retrying.
          elsif ['410'].include?(result[:http_code])
            # Log error & skip to next record
            add_error(params[:url], result[:http_code], e, proxy_for_log, result[:tries])
            break # Stop retrying.
          else
            add_error(params[:url], result[:http_code], e, proxy_for_log, result[:tries])
            break # Stop retrying.
          end
        rescue Net::HTTP::Persistent::Error => e
          # Network down? Sleep 60 seconds & try again
          result[:http_code] = '696'
          result[:errors] << e.message + (proxy.present? ? " -- #{proxy[:host]}:#{proxy[:port]}" : '')
          add_error(params[:url], result[:http_code], e, proxy_for_log, result[:tries])
          sleep(sleep_secs) unless Rails.env == 'test'
        rescue Net::HTTPClientException => e
          # We don't need to log these codes. Do not retry 404 or 410
          if e.message.include?('404')
            result[:http_code] = '404'
            break # while
          elsif e.message.include?('410')
            result[:http_code] = '410'
            break # while
          # Shifter.io proxy will return 420 if they are rotating proxies
          elsif e.message.include?('420')
            result[:http_code] = '420'
            add_error(params[:url], result[:http_code], e, proxy_for_log, result[:tries])
            sleep(sleep_secs) unless Rails.env == 'test'
          else
            result[:http_code] = '697'
            result[:errors] << e.message
            add_error(params[:url], result[:http_code], e, proxy_for_log, result[:tries])
            sleep(sleep_secs) unless Rails.env == 'test'
          end
        rescue Net::HTTPFatalError => e
          result[:http_code] = '698'
          result[:errors] << "#{e.class} => #{e.message}"
          add_error_with_class(params[:url], result[:http_code], e, proxy_for_log, result[:tries])
          sleep(sleep_secs) unless Rails.env == 'test'
          # break
        rescue StandardError => e
          if e.message.include?('429')
            # Slow down
            result[:http_code] = '429'
            result[:errors] << e.message
            add_error(params[:url], result[:http_code], e, proxy_for_log, result[:tries])
            sleep(sleep_secs) unless Rails.env == 'test'
          else
            result[:http_code] = '699'
            result[:errors] << e.message
            add_error_with_class(params[:url], result[:http_code], e, proxy_for_log, result[:tries])
            sleep(sleep_secs) unless Rails.env == 'test'
          end
          # break
        end # begin
      end # while retries < max_retries + 1
    end # Mechanize.start
    page = nil
    result
  end # def

  def log_error(message)
    agent_logger.error(message.to_s)
  end

  def add_error(url, http_code, error, proxy_data, tries = '')
    log_error("ERROR: #{url}, http_code: #{http_code}, errors: #{error.message}, proxy: #{proxy_data}, tries: #{tries}, timestamp: #{Time.zone.now}")
  end

  def add_error_with_class(url, http_code, error, proxy_data, tries = '')
    log_error("ERROR: #{url}, http_code: #{http_code}, errors: #{error.class} => #{error.message}, proxy: #{proxy_data}, tries: #{tries}, timestamp: #{Time.zone.now}")
  end

  def agent_logger
    al = Logger.new("#{Rails.root}/log/agent_logic.log")
    # Log levels: :debug, :info, :warn, :error, :fatal, :unknown
    al.level = Rails.env == 'production' ? Logger::ERROR : Logger::DEBUG
    al
  end
end # module
