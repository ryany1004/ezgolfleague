class AddUserAttributes < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.string :first_name
      t.string :last_name
      t.string :phone_number
      t.string :street_address_1
      t.string :street_address_2
      t.string :city
      t.string :us_state
      t.string :postal_code
    end
  end
end
