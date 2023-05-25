# frozen_string_literal: true

class CheckGroupAssignmentService
  def initialize(vote_account_id:)
    @vote_account = VoteAccount.find(vote_account_id)
    @network = @vote_account.network
    @groups_list = []
    @unassigned_list = []
    @group = nil
  end

  def call
    assign_by_authorized_withdrawer_or_validator_identity
    assign_by_authorized_voters
    return if @groups_list.empty? && @unassigned_list.empty?
    find_or_create_group
    assign_validators_to_group
    move_validators_to_group
    delete_empty_groups
  end

  private
  
  def assign_by_authorized_withdrawer_or_validator_identity
    return unless @vote_account.authorized_withdrawer || @vote_account.validator_identity
    VoteAccount.where(authorized_withdrawer: @vote_account.authorized_withdrawer, network: @network)
                .or(VoteAccount.where(validator_identity: @vote_account.validator_identity, network: @network))
                .each do |va|
                  next if va == @vote_account
                  
                  if va.validator.group
                    @groups_list << va.validator.group.id
                  else
                    @unassigned_list << va.validator_id
                  end
    end
  end

  def assign_by_authorized_voters
    return unless @vote_account.authorized_voters
    @vote_account.authorized_voters.each do |epoch, voter|
      puts "epoch: #{epoch}, voter: #{voter}"
      VoteAccount.where(network: @network).each do |va|
        next if va == @vote_account
        next unless va.authorized_voters&.values&.include?(voter)

        if va.validator.group
          @groups_list << va.validator.group.id
        else
          @unassigned_list << va.validator_id
        end
      end
    end
  end

  def find_or_create_group
    if @groups_list.empty?
      @group = Group.create
    else
      @group = Group.find(@groups_list.first)
    end
  end

  def assign_validators_to_group
    @unassigned_list.each do |validator_id|
      validator = Validator.find(validator_id)
      GroupValidator.create(group: @group, validator: validator)
    end
    GroupValidator.create(group: @group, validator: @vote_account.validator)
  end

  def move_validators_to_group
    @groups_list.each do |group_id|
      group = Group.find(group_id)
      group.validators.each do |validator|
        validator.group = @group
        validator.save
      end
    end
  end

  def delete_empty_groups
    Group.where(id: @groups_list).each do |group|
      if group.validators.empty?
        group.destroy
      end
    end
  end
end
