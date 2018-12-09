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
      end

  		raise "No Scoring Rule" if rule.blank?

      #add the users
      d.tournament.players_for_day(d).each do |user|
        rule.users << user
      end

  		d.scoring_rules = [rule]
  		d.game_type_id = nil
  		d.save

      #convert contests
  	end
  end
end