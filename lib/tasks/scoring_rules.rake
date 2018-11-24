namespace :scoring_rules do
  desc 'Convert Stroke Play to Scoring Rules'
  task convert_stroke_play: :environment do
  	TournamentDay.where(game_type_id: 1).each do |d|
  		rule = StrokePlayScoringRule.create
      rule.save

  		d.scoring_rules = [rule]
  		d.game_type_id = nil
  		d.save
  	end
  end
end