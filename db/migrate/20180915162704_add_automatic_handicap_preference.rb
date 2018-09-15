class AddAutomaticHandicapPreference < ActiveRecord::Migration[5.1]
  def change
  	add_column :leagues, :calculate_handicaps_from_past_rounds, :boolean, default: false

  	League.all.each do |l|
  		l.calculate_handicaps_from_past_rounds = false
  		l.save
  	end
  end
end
