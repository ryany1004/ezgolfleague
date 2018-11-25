namespace :scoring_rules do
  desc 'Convert Game Type to Scoring Rules'
  task convert_game_type_to_scoring_rules: :environment do
  	TournamentDay.all.each do |d|
      case d.game_type_id
      when 1
        rule = StrokePlayScoringRule.create

        GameTypeMetadatum.all.where(search_key: rule.legacy_use_back_nine_key).update_all(search_key: rule.use_back_nine_key)
      when 2
        rule = MatchPlayScoringRule.create
      when 3
        rule = StablefordScoringRule.create

        raise "Needs Metadata Transform"
      end

  		raise "No Scoring Rule" if rule.blank?

  		d.scoring_rules = [rule]
  		d.game_type_id = nil
  		d.save
  	end
  end
end