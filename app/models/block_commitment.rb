class BlockCommitment < ApplicationRecord
  serialize :commitment, JSON

  # params:
  #   network: the network
  #   slot: the slot
  #   commitment: JSON commitment result from the RPC call
  #   total_stake: The total active stake in effect
  def self.stuff_it(params)
    block_commitment = find_or_create_by(
                         network: params[:network],
                         slot: params[:slot]
                       )
    block_commitment.commitment = params[:commitment] \
      unless params[:commitment].nil?
    block_commitment.total_stake = params[:total_stake] \
      unless params[:total_stake].nil?
    block_commitment.save
  end
end
