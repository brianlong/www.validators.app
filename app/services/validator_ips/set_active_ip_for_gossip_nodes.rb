module ValidatorIps
  # WARNING: Run service with "run_destroy: true" argument and you'll destroy data centers, 
  # without you'll get only logs and see what will be updated.
  class SetActiveIpForGossipNodes
    LOG_PATH = Rails.root.join("log", "#{self.name.demodulize.underscore}.log")
    START_MESSAGE = "SCRIPT HAS STARTED"
    FINISH_MESSAGE = "SCRIPT HAS FINISHED"
    SEPARATOR = "-" * 20

    def initialize(run_update: false)
      @logger ||= Logger.new(LOG_PATH)
      @run_update = run_update
    end

    def call
      log_message("#{SEPARATOR}#{START_MESSAGE}, run update: #{@run_update}#{SEPARATOR}")

      set_is_active_in_inactive_vips_without_validator_id
      set_is_active_in_inactive_vips_with_validator_id

      log_message("#{SEPARATOR}#{FINISH_MESSAGE}#{SEPARATOR}")
    end

    private

    def set_is_active_in_inactive_vips_without_validator_id
      vips_without_val_id = ValidatorIp.joins(:gossip_node)
                                       .where(validator_id: nil, is_active:false)
                                       .distinct
            
      message = <<-EOS
        Number of inactive validator ips connected with gossip nodes, where validator_id is nil: #{vips_without_val_id.size}.
      EOS

      log_message(message)

      vips_without_val_id.update_all(is_active: true) if @run_update
    end

    def set_is_active_in_inactive_vips_with_validator_id
      ValidatorIp.joins(:gossip_node)
                 .where("validator_ips.is_active = false AND validator_ips.validator_id IS NOT NULL")
                 .find_each do |validator_ip|

        message = <<-EOS
          Processing vip with address #{validator_ip.address} (##{validator_ip.id}).
        EOS

        log_message(message)

        gossip_node = validator_ip.gossip_node
        validator = validator_ip.validator
        validator_ip_active = validator&.validator_ip_active

        if validator_ip_active.present?
          message = <<-EOS
            Validator #{validator.name} (##{validator.id}) connected with active vip #{validator_ip_active.address} (##{validator_ip_active.id}).
          EOS

          log_message(message)
        end

        if validator_ip.id != validator_ip_active.id
          message = <<-EOS
            Validator #{validator.name} (##{validator.id}) is connected to active vip with different id (##{validator_ip_active.id})
            than currently processed vip (##{validator_ip.id}) connected to gossip node, 
            vip set to active and validator_id is nullified.
          EOS

          log_message(message)

          validator_ip.update(validator_id: nil, is_active: true) if @run_update
        end
      end
    end


    def log_message(message, type: :info)
      # Remove unless clause to see log file from tests.
      @logger.send(type, message.squish) unless Rails.env.test?
    end
  end
end
