# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

require 'securerandom'

client_data = [
  {
    external_id: '1',
    name: 'John Doe',
    email: 'john.doe@example.com',
    phone: '+1-555-123-4567'
  },
  {
    external_id: '2', 
    name: 'Jane Smith',
    email: 'jane.smith@example.com',
    phone: '+1-555-987-6543'
  },
  {
    external_id: '3',
    name: 'Bob Johnson', 
    email: 'bob.johnson@example.com',
    phone: '+1-555-456-7890'
  },
  {
    external_id: '4',
    name: 'Alice Williams',
    email: 'alice.williams@example.com', 
    phone: '+1-555-321-6549'
  },
  {
    external_id: '5',
    name: 'David Brown',
    email: 'david.brown@example.com',
    phone: '+1-555-654-3210'
  }
]

client_data.each do |data|
  client = Client.find_or_initialize_by(external_id: data[:external_id])
  client.assign_attributes(data)
  client.save!
  puts "Created/Updated client: #{client.name}"
end

appointment_types = ['Initial Consultation', 'Follow-up', 'Therapy Session', 'Group Session', 'Assessment']
statuses = ['scheduled', 'completed', 'cancelled']

Clients = Client.all

15.times do |i|
  client = Clients.sample
  scheduled_time = case i % 3
                  when 0
                    rand(30.days).seconds.ago + rand(7.days).seconds
                  when 1
                    rand(30.days).seconds.from_now
                  else
                    rand(2.days).seconds.ago + rand(1.day).seconds
                  end
  
  appointment = Appointment.find_or_initialize_by(
    external_id: "appt_#{i + 1}"
  )
  
  appointment.assign_attributes(
    client: client,
    appointment_type: appointment_types.sample,
    scheduled_at: scheduled_time,
    status: scheduled_time < Time.current ? statuses.sample : 'scheduled',
    notes: "Sample appointment notes for #{client.name}"
  )
  
  appointment.save!
  puts "Created/Updated appointment: #{appointment.appointment_type} for #{client.name} at #{appointment.scheduled_at}"
end

puts "\n✅ Seeds completed!"
puts "Created #{Client.count} clients and #{Appointment.count} appointments"
