class ClientSerializer
  include JSONAPI::Serializer

  attributes :name, :email, :phone, :created_at, :updated_at

  has_many :appointments
end
