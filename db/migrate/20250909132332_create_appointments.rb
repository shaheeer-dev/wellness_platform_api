class CreateAppointments < ActiveRecord::Migration[7.2]
  def change
    create_table :appointments do |t|
      t.string :external_id, null: false
      t.references :client, null: false, foreign_key: true
      t.string :appointment_type, null: false
      t.datetime :scheduled_at, null: false
      t.string :status, null: false, default: 'scheduled'
      t.text :notes
      t.datetime :cancelled_at
      t.text :cancellation_reason

      t.timestamps
    end
    add_index :appointments, :external_id, unique: true
    add_index :appointments, :status
    add_index :appointments, :scheduled_at
    add_index :appointments, :cancelled_at
  end
end
