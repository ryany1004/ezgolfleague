class AddBalanceOptOut < ActiveRecord::Migration[5.1]
  def change
  	 change_table :leagues do |t|
  	 	t.boolean :display_balances_to_players, default: true
    end

    League.all.each do |l|
    	l.display_balances_to_players = true
    	l.save
    end
  end
end
