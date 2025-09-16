FactoryBot.define do
  factory :appointment do
    external_id { SecureRandom.uuid }
    client
    appointment_type { 'Consultation' }
    scheduled_at { 1.week.from_now }
    status { 'scheduled' }
    notes { 'Sample appointment notes' }
  end
end
