FactoryBot.define do
  factory :commission_history do
    validator
    commission_before { 10 }
    commission_after { 20 }
    batch_uuid { "batch-123" }
  end
end
