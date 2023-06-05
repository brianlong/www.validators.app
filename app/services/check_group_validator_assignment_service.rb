# frozen_string_literal: true

class CheckGroupValidatorAssignmentService
  LOG_PATH = Rails.root.join("log", "#{self.name.demodulize.underscore}.log")

  def initialize(vote_account_id:, log_path: LOG_PATH)
    @vote_account = VoteAccount.find(vote_account_id)
    @vote_account_group = @vote_account.validator.group
    @network = @vote_account.network
    @groups_list = []
    @unassigned_list = []
    @group = nil
    @logger ||= Logger.new(log_path)
  end

  def call
    log_message("checking vote account ##{@vote_account.account} for group assignment")
    assign_by_authorized_withdrawer_or_validator_identity
    assign_by_authorized_voters
    log_message("linked groups: #{@groups_list}")
    log_message("linked validators: #{@unassigned_list}")
    return if @groups_list.empty? && @unassigned_list.empty?

    find_or_create_group
    log_message("used group: #{@group}")
    assign_validators_to_group
    move_validators_to_group
    delete_empty_groups
    log_message("-----------------------")
  end

  private
  
  def assign_by_authorized_withdrawer_or_validator_identity
    return unless @vote_account.authorized_withdrawer || @vote_account.validator_identity

    VoteAccount.includes(validator: :group)
               .where(authorized_withdrawer: @vote_account.authorized_withdrawer, network: @network)
               .or(VoteAccount.where(validator_identity: @vote_account.validator_identity, network: @network))
               .each do |va|
                 next if va.validator == @vote_account.validator

                 if va.validator.group
                   @groups_list << group_list_elemnt(va)
                 else
                   @unassigned_list << unassigned_list_element(va)
                 end
               end
  end

  def assign_by_authorized_voters
    return unless @vote_account.authorized_voters

    @vote_account.authorized_voters.each do |epoch, voter|
      VoteAccount.where(network: @network).find_each do |va|
        next if va == @vote_account
        next unless va.authorized_voters&.values&.include?(voter)

        if va.validator.group
          @groups_list << group_list_elemnt(va)
        else
          @unassigned_list << unassigned_list_element(va)
        end
      end
    end
  end

  def group_list_elemnt(va)
    {
      group_id: va.validator.group.id,
      link_reason: {
        va.id => if va.authorized_withdrawer == @vote_account.authorized_withdrawer
                   "authorized_withdrawer"
                 elsif  va.validator_identity == @vote_account.validator_identity
                   "validator_identity"
                 else
                   "authorized_voters"
                 end
      }
    }
  end

  def unassigned_list_element(va)
    {
      validator_id: va.validator.id,
      link_reason: {
        va.id => if va.authorized_withdrawer == @vote_account.authorized_withdrawer
                   "authorized_withdrawer"
                 elsif  va.validator_identity == @vote_account.validator_identity
                   "validator_identity"
                 else
                   "authorized_voter"
                 end
      }
    }
  end

  def find_or_create_group
    if @groups_list.empty?
      @group = Group.create(network: @network)
    else
      @group = Group.find(@groups_list.first[:group_id])
    end
  end

  def assign_validators_to_group
    @unassigned_list.each do |unassigned_element|
      validator = Validator.find(unassigned_element[:validator_id])
      GroupValidator.create(
        group: @group,
        validator: validator,
        link_reason: unassigned_element[:link_reason]
      ) unless @group.validators.include?(validator)
    end
    GroupValidator.create(group: @group, validator: @vote_account.validator) \
      unless @group.validators.include?(@vote_account.validator)
  end

  def move_validators_to_group
    @groups_list.uniq.each do |group_element|
      group = Group.find(group_element[:group_id])
      group.validators.each do |validator|
        validator.group_validator.destroy
        GroupValidator.create(
          group: @group,
          validator: validator,
          link_reason: group_element[:link_reason]
        )
      end
    end
  end

  def delete_empty_groups
    @vote_account_group.destroy if @vote_account_group&.validators&.empty?

    Group.where(id: @groups_list).each do |group|
      if group.validators.empty?
        group.destroy
        log_message("deleted empty group ##{group.id}")
      end
    end
  end

  def log_message(message, type: :info)
    @logger.send(type, message.squish) unless Rails.env.test?
  end
end
