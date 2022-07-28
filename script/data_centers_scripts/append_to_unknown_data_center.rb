# frozen_string_literal: true

# RAILS_ENV=production bundle exec ruby script/data_centers_scripts/append_to_unknown_data_center.rb
require_relative '../../config/environment'
log_path = Rails.root.join('log', 'append_to_unknown_data_center.log')
@logger ||= Logger.new(log_path)

@logger.info "Script has started at #{Time.now}"

begin
  data_center_key = ARGV[0] || "0--Unknown"
  unknown_data_center = DataCenter.find_by(data_center_key: data_center_key)
  service = DataCenters::AppendToDataCenter.new(unknown_data_center)

  # Data center for validators without data_center assigned
  # most cases does not provide IP so we cannot assign them
  # because we cannot check their IP in MaxMind. 
  validators_active_without_data_center = Validator.active.where.missing(:data_center)
  
  validators_active_without_data_center.each do |val|
    # We don't want to assign new validators to Unknown data center
    # we want to wait some time 
    if val.created_at < Date.today - 5.days
      service.call(val)

      val.reload

      info = <<-EOS 
        Validator #{val.name} (##{val.id}) 
        assigned to data center #{unknown_data_center.data_center_key} (##{unknown_data_center.id});
        validator_ip: ##{val.validator_ip_active.id}, data_center_host: ##{val.data_center_host.id}"
      EOS

      @logger.info info.squish
    end
  end

  @logger.info "Script has finished at #{Time.now}"
end
