require 'rails_helper'

RSpec.describe Appointment, type: :model do
  describe 'associations' do
    it { should belong_to(:client) }
  end

  describe 'validations' do
    subject { build(:appointment) }

    it { should validate_presence_of(:external_id) }
    it { should validate_uniqueness_of(:external_id) }
    it { should validate_presence_of(:appointment_type) }
    it { should validate_presence_of(:scheduled_at) }

    describe 'status validation' do
      it 'accepts valid status values' do
        %w[scheduled completed cancelled].each do |status|
          appointment = build(:appointment, status: status)
          expect(appointment).to be_valid
        end
      end

      it 'rejects invalid status values' do
        appointment = build(:appointment)
        expect {
          appointment.status = 'invalid_status'
        }.to raise_error(ArgumentError, /is not a valid status/)
      end
    end
  end

  describe 'status enum functionality' do
    it 'defines status enum with correct values' do
      expect(Appointment.statuses).to eq({
        'scheduled' => 'scheduled',
        'completed' => 'completed',
        'cancelled' => 'cancelled'
      })
    end

    describe 'status query and setter methods' do
      let(:appointment) { create(:appointment, status: 'scheduled') }

      it 'provides boolean query methods for each status' do
        expect(appointment.scheduled?).to be true
        expect(appointment.completed?).to be false
        expect(appointment.cancelled?).to be false
      end

      it 'allows changing status using setter methods' do
        appointment.completed!
        expect(appointment.completed?).to be true
        expect(appointment.status).to eq('completed')
      end
    end
  end

  describe 'creation and persistence' do
    it 'creates a valid appointment with all required attributes' do
      appointment = build(:appointment)
      expect(appointment).to be_valid
    end

    it 'persists appointment with associated client relationship' do
      appointment = create(:appointment)
      expect(appointment.client).to be_present
      expect(appointment.client).to be_a(Client)
    end
  end

  describe 'date and time handling' do
    let(:client) { create(:client) }

    it 'accepts future appointment dates' do
      appointment = build(:appointment, client: client, scheduled_at: 1.week.from_now)
      expect(appointment).to be_valid
    end

    it 'accepts past appointment dates for historical records' do
      appointment = build(:appointment, client: client, scheduled_at: 1.week.ago)
      expect(appointment).to be_valid
    end
  end

  describe 'data integrity and constraints' do
    let(:client) { create(:client) }

    it 'rejects invalid status values' do
      expect {
        create(:appointment, client: client, status: 'invalid_status')
      }.to raise_error(ArgumentError, /is not a valid status/)
    end

    it 'handles lengthy appointment type descriptions' do
      long_type = 'Extended therapy session with comprehensive evaluation and treatment planning' * 3
      appointment = build(:appointment, client: client, appointment_type: long_type)
      expect(appointment).to be_valid
    end
  end

  describe 'optional attributes' do
    it 'stores appointment notes when provided' do
      appointment = create(:appointment, notes: 'Patient requires wheelchair accessibility')
      expect(appointment.notes).to eq('Patient requires wheelchair accessibility')
    end

    it 'allows appointments without notes' do
      appointment = create(:appointment, notes: nil)
      expect(appointment.notes).to be_nil
    end
  end
end
