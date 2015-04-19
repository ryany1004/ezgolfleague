class CreateFlights < ActiveRecord::Migration
  def change
    create_table :flights do |t|
      t.integer :tournament_id, index: true
      t.integer :flight_number
      t.timestamps null: false
    end
        
    create_table :flights_users, id: false do |t|
      t.belongs_to :flight, index: true
      t.belongs_to :user, index: true
    end
  end
end