module ValidatorIps
  class RemoveDuplicatedInactiveValidatorIps
    LOG_PATH = Rails.root.join("log", "#{self.name.demodulize.underscore}.log")
    START_MESSAGE = "SCRIPT HAS STARTED"
    FINISH_MESSAGE = "SCRIPT HAS FINISHED"
    SEPARATOR = "-" * 20

    def initialize(run_destroy: false)
      @logger ||= Logger.new(LOG_PATH)
      @run_destroy = run_destroy
    end

    def call
      log_message("#{SEPARATOR}#{START_MESSAGE}, run destroy: #{@run_destroy}#{SEPARATOR}")

      inactive_vips = ValidatorIp.where(is_active: false).group(:address).count
      duplicated_vips = inactive_vips.select { |_k, v| v > 1 }

      duplicated_vip_objects = ValidatorIp.where(is_active: false, address: duplicated_vips.keys)

      duplicated_vip_objects.each do |dup|
        message = <<-EOS
          Processing Validator Ip with address #{dup.address} (##{dup.id}).
        EOS

        log_message(message)

        remove_vip(dup)
      end

      log_message("#{SEPARATOR}#{FINISH_MESSAGE}#{SEPARATOR}")
    end

    private

    def remove_vip(validator_ip)
      validator = validator_ip.validator
      gossip_node = validator_ip.gossip_node
      validator_ip_active = validator&.validator_ip_active
      gossip_node_ip_active = gossip_node&.validator_ip_active

      if validator
        message = <<-EOS
          Validator Ip has validator #{validator.name} (##{validator.id}) connected.
        EOS

        log_message(message)
      else
        message = <<-EOS
          Validator Ip does not have validator connected.
        EOS

        log_message(message)
      end

      if gossip_node
        message = <<-EOS
          Validator Ip has gossip node (##{gossip_node.id}) connected.
        EOS

        log_message(message)
      else
        message = <<-EOS
          Validator Ip does not have gossip node connected.
        EOS

        log_message(message)
      end

      if validator_ip_active.present?
        message = <<-EOS
          Validator has validator ip active #{validator_ip_active.address} (##{validator_ip_active.id}) connected.
        EOS

        log_message(message)
      else
        if validator
          message = <<-EOS
            Validator #{validator&.name} (##{validator&.id}) does not have active vip.
          EOS

          log_message(message)
        end
      end

      if gossip_node_ip_active.present?
        message = <<-EOS
          Gossip node has validator ip active #{gossip_node_ip_active.address} (##{gossip_node_ip_active.id}) connected.
        EOS

        log_message(message)
      else
        if gossip_node
          message = <<-EOS
            Gossip node ##{gossip_node.id} does not have active vip.
          EOS

          log_message(message)
        end
      end

      if validator_ip_to_destroy?(validator, validator_ip_active, gossip_node, gossip_node_ip_active)
        message = <<-EOS
          Validator Ip will be removed.
        EOS

        log_message(message, type: :warn)

        validator_ip.destroy if @run_destroy
      end
    end

    def validator_ip_to_destroy?(validator, validator_ip_active, gossip_node, gossip_node_ip_active)
      (!validator.present? && !gossip_node.present?) || 
      (validator.present? && validator_ip_active.present? && !gossip_node.present?) || 
      (gossip_node.present? && gossip_node_ip_active.present? && !validator.present?) ||
      (gossip_node.present? && gossip_node_ip_active.present? && validator.present? && validator_ip_active.present?)
    end

    def log_message(message, type: :info)
      # Remove unless clause to see log file from tests.
      @logger.send(type, message.squish) unless Rails.env.test?
    end
  end
end