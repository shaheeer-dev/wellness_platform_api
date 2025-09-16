class AppointmentSerializer
  include JSONAPI::Serializer

  attributes :appointment_type, :scheduled_at, :status, :notes, :created_at, :updated_at

  belongs_to :client

  attribute :scheduled_at_formatted do |appointment|
    appointment.scheduled_at&.strftime('%B %d, %Y at %I:%M %p')
  end

  attribute :is_upcoming do |appointment|
    appointment.scheduled_at.present? && appointment.scheduled_at > Time.current
  end
end
