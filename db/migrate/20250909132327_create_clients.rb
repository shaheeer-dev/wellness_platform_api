class CreateClients < ActiveRecord::Migration[7.2]
  def change
    create_table :clients do |t|
      t.string :external_id, null: false
      t.string :name, null: false
      t.string :email, null: false
      t.string :phone

      t.timestamps
    end
    add_index :clients, :external_id, unique: true
    add_index :clients, :email, unique: true
  end
end
