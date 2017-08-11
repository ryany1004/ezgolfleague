class AddCoordinates < ActiveRecord::Migration[4.2]
  def change
    change_table :courses do |t|
      t.float :latitude
      t.float :longitude

      Course.all.each do |c| c.geocode end
    end
  end
end
