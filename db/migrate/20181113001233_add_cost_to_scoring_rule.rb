class AddCostToScoringRule < ActiveRecord::Migration[5.1]
  def change
  	add_column :scoring_rules, :is_opt_in, :boolean, default: false
  	add_column :scoring_rules, :dues_amount, :decimal, default: 0

  	TournamentDay.all.each do |d|
  		rule = d.scoring_rules.first

  		unless rule.blank?
  			rule.dues_amount = d.tournament.dues_amount
  			rule.save
  		end
  	end

  	remove_column :tournaments, :dues_amount
  end
end
