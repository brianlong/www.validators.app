class Blockchain::MainnetSlot < Blockchain::Slot
    enum status: { initialized: 0, has_block: 1, no_block: 2, request_error: 3 }

end
