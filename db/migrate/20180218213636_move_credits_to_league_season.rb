class MoveCreditsToLeagueSeason < ActiveRecord::Migration[5.1]
  def change
  	add_column :subscription_credits, :league_season_id, :integer

  	SubscriptionCredit.all.each do |s|
  		league = League.where(id: s.league_id).first

  		unless league.blank?
  			s.league_season = league.active_season
  			s.save
  		end
  	end

  	remove_column :subscription_credits, :league_id
  end
end
