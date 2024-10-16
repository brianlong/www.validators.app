Blockchain::MainnetSlot.where(epoch: 684).group_by(&:leader).map{ |k, v| {k => v.map(&:slot_number)}}

start_slot = Blockchain::MainnetSlot.where(epoch: 685).first.slot_number
end_slot = start_slot + 43199

leaders_data = Blockchain::MainnetBlock.joins("JOIN blockchain_mainnet_slots ON blockchain_mainnet_slots.slot_number = blockchain_mainnet_blocks.slot_number")
    .select("blockchain_mainnet_slots.epoch AS epoch, blockchain_mainnet_slots.leader AS leader, blockchain_mainnet_blocks.slot_number AS slot_number")
    .where("blockchain_mainnet_slots.epoch = ?", 684)
    .group_by(&:leader)

leaders_results = leaders_data.map do |leader, blocks|
    previous_slot = nil
    current_slot = nil
    highest_diff = 0
    blocks.each do |block|
        previous_slot = current_slot
        current_slot = block.slot_number
        diff = current_slot - previous_slot if previous_slot
        highest_diff = diff if diff && diff > highest_diff
    end
    {leader => highest_diff}
end

puts leaders_results