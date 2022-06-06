require_relative '../../config/environment'
log_path = Rails.root.join('log', 'lock_access_for_users.log')
@logger ||= Logger.new(log_path)

User.all.in_batches.each do |batch|
  batch.each do |user|
    if user.valid? 
      next
    else
      warn_message = <<-EOS 
        User #{user.username} is invalid, access locked. Errors: #{user.errors.full_messages}
      EOS
      
      @logger.warn(warn_message)
      user.lock_access!
    end
  end
end