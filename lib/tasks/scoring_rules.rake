namespace :scoring_rules do
  desc 'Convert Stroke Play to Scoring Rules'
  task convert_stroke_play: :environment do
  	TournamentDay.where(game_type_id: 1).each do |d|
  		rule = StrokePlayScoringRule.create

  		d.scoring_rules = [rule]
  		d.game_type_id = nil
  		d.save

  		d.payout_results.each do |p|
  			p.tournament_day = nil
  			p.scoring_rule = rule
  			p.save
  		end
  	end
  end
end