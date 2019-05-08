class AddNumberOfHandicapRounds < ActiveRecord::Migration[5.2]
  def change
    add_column :leagues, :number_of_rounds_to_handicap, :integer, default: 10
  
    League.all.each do |l|
      l.number_of_rounds_to_handicap = 10
      l.save
    end
  end
end
