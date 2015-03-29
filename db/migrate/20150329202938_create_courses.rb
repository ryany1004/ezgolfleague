class CreateCourses < ActiveRecord::Migration
  def change
    create_table :courses do |t|
      t.string :name
      t.string :phone_number
      t.string :street_address_1
      t.string :street_address_2
      t.string :city
      t.string :us_state
      t.string :postal_code
      t.timestamps null: false
    end
  end
end
