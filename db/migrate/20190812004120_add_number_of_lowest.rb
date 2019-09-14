class AddNumberOfLowest < ActiveRecord::Migration[5.2]
  def change
    add_column :leagues, :number_of_lowest_rounds_to_handicap, :integer, default: 10
    change_column_default :leagues, :number_of_rounds_to_handicap, default: 20

    League.all.each do |l|
      l.number_of_lowest_rounds_to_handicap = l.number_of_rounds_to_handicap
      l.save
    end
  end
end
