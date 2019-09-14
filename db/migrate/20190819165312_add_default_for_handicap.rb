class AddDefaultForHandicap < ActiveRecord::Migration[5.2]
  def change
    change_column_default(:leagues, :number_of_rounds_to_handicap, 20)
  end
end
