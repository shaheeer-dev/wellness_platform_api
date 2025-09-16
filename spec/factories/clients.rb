FactoryBot.define do
  factory :client do
    external_id { SecureRandom.uuid }
    sequence(:name) { |n| "Client #{n}" }
    sequence(:email) { |n| "client#{n}@example.com" }
    phone { "+1-555-555-5555" }
  end
end
