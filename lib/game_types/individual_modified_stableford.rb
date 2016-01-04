module GameTypes
  class IndividualModifiedStableford < GameTypes::IndividualStrokePlay

    def display_name
      return "Individual Modified Stableford"
    end
    
    def game_type_id
      return 3
    end
    
    ##Scoring
    
    def related_scorecards_for_user(user, only_human_scorecards = false)
      other_scorecards = []
      
      other_scorecards << self.stableford_scorecard_for_user(user, self.tournament_day.tournament_group_for_player(user)) if only_human_scorecards == false
      
      self.tournament_day.other_group_members(user).each do |player|
        other_scorecards << self.tournament_day.primary_scorecard_for_user(player)
        other_scorecards << self.stableford_scorecard_for_user(player, self.tournament_day.tournament_group_for_player(player)) if only_human_scorecards == false
      end
      
      return other_scorecards
    end

    def stableford_scorecard_for_user(user, golfer_team)
      scorecard = IndividualStablefordScorecard.new
      scorecard.user = user
      scorecard.golfer_team = golfer_team
      scorecard.calculate_scores

      return scorecard
    end

    def flights_with_rankings #TODO
      return []
    end

  end
end