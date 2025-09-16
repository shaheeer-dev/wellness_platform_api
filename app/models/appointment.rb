class Appointment < ApplicationRecord
  belongs_to :client

  enum :status, {
    scheduled: 'scheduled',
    completed: 'completed',
    cancelled: 'cancelled'
  }

  validates :external_id, presence: true, uniqueness: true
  validates :appointment_type, presence: true
  validates :scheduled_at, presence: true
  validates :status, inclusion: { in: statuses.keys }

  scope :active, -> { where.not(status: 'cancelled') }
  scope :cancelled_on, ->(date) { where(cancelled_at: date.beginning_of_day..date.end_of_day) }
  scope :cancelled_after, ->(date) { where('cancelled_at >= ?', date) }

  def cancel!(reason = nil)
    raise StandardError, "Cannot cancel appointment: #{cancellation_validation_error}" unless can_be_cancelled?

    update!(
      status: 'cancelled',
      cancelled_at: Time.current,
      cancellation_reason: reason || 'No reason provided'
    )
  end

  def can_be_cancelled?
    scheduled? && scheduled_at > Time.current
  end

  private

  def cancellation_validation_error
    return "appointment is already #{status}" unless scheduled?
    return "appointment is in the past" unless scheduled_at > Time.current
    nil
  end
end
