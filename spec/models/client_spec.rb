require 'rails_helper'

RSpec.describe Client, type: :model do
  describe 'associations' do
    it { should have_many(:appointments).dependent(:destroy) }
  end

  describe 'validations' do
    subject { build(:client) }
    
    it { should validate_presence_of(:external_id) }
    it { should validate_uniqueness_of(:external_id) }
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email) }
    it { should allow_value('test@example.com').for(:email) }
    it { should_not allow_value('invalid_email').for(:email) }
    it { should validate_length_of(:phone).is_at_most(25) }
  end

  describe 'factory' do
    it 'creates a valid client' do
      client = build(:client)
      expect(client).to be_valid
    end
  end
end
