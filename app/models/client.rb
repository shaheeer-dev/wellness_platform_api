class Client < ApplicationRecord
  has_many :appointments, dependent: :destroy

  validates :external_id, presence: true, uniqueness: true
  validates :name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :phone, allow_blank: true, length: { maximum: 25 }
end
