class AddCustomerLeagueInfo < ActiveRecord::Migration[5.1]
  def change
  	 change_table :leagues do |t|
  	 	t.string :league_type
  	 	t.text :more_comments
    end
  end
end
