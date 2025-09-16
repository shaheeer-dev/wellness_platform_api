# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2025_09_09_132332) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "appointments", force: :cascade do |t|
    t.string "external_id", null: false
    t.bigint "client_id", null: false
    t.string "appointment_type", null: false
    t.datetime "scheduled_at", null: false
    t.string "status", default: "scheduled", null: false
    t.text "notes"
    t.datetime "cancelled_at"
    t.text "cancellation_reason"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cancelled_at"], name: "index_appointments_on_cancelled_at"
    t.index ["client_id"], name: "index_appointments_on_client_id"
    t.index ["external_id"], name: "index_appointments_on_external_id", unique: true
    t.index ["scheduled_at"], name: "index_appointments_on_scheduled_at"
    t.index ["status"], name: "index_appointments_on_status"
  end

  create_table "clients", force: :cascade do |t|
    t.string "external_id", null: false
    t.string "name", null: false
    t.string "email", null: false
    t.string "phone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_clients_on_email", unique: true
    t.index ["external_id"], name: "index_clients_on_external_id", unique: true
  end

  add_foreign_key "appointments", "clients"
end
