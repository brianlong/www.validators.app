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

      GossipNode.find_each do |gossip_node|
        next if gossip_node.validator_ip_active

        message = <<-EOS
          Processing Gossip Node with address #{gossip_node.ip} (##{gossip_node.id}).
        EOS

        log_message(message)

        gossip_node_validator_ip = gossip_node.validator_ip
        validator = gossip_node_validator_ip&.validator
        validator_ip_active = validator&.validator_ip_active

        if validator 
          message = <<-EOS
            Validator Ip connected with validator #{validator.name} (##{validator.id}).
          EOS

          log_message(message)
        end

        if validator_ip_active.present?
          message = <<-EOS
            Validator connected with active ip #{validator_ip_active.address} (##{validator_ip_active.id}).
          EOS

          log_message(message)
        end

        if gossip_node_validator_ip&.id == validator_ip_active&.id
          message = <<-EOS
            Gossip node validator ip (##{gossip_node_validator_ip&.id}) is the same as 
            validator's ip active (##{validator_ip_active&.id}), skipping.
          EOS

          next
        else
          message = <<-EOS
            Validator Ip #{gossip_node_validator_ip.address} (##{gossip_node_validator_ip.id}) will be set to active.
          EOS

          log_message(message)

          gossip_node_validator_ip.update(is_active: true) if @run_update
        end
      end

      log_message("#{SEPARATOR}#{FINISH_MESSAGE}#{SEPARATOR}")
    end

    private

    def log_message(message, type: :info)
      # Remove unless clause to see log file from tests.
      @logger.send(type, message.squish) unless Rails.env.test?
    end
  end
end