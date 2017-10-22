class AddFreeCredits < ActiveRecord::Migration[5.1]
  def change
  	change_table :leagues do |t|
  		t.integer :free_tournaments_remaining, default: 2
    end

    League.all.each do |l|
    	l.free_tournaments_remaining = 2
    	l.save
    end
  end
end
