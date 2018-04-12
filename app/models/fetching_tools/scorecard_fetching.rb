module FetchingTools
  class ScorecardFetching
    
    def self.fetch_scorecards_and_related(scorecard_id)
      scorecard = Scorecard.includes(scores: [:course_hole], golf_outing: [:user]).find(scorecard_id)
      tournament_day = scorecard.golf_outing.tournament_group.tournament_day
      tournament = tournament_day.tournament
      
      if tournament_day.game_type.show_other_scorecards?
        other_scorecards = tournament_day.related_scorecards_for_user(scorecard.golf_outing.user)
      else
        other_scorecards = []
      end

      return {:scorecard => scorecard, :tournament_day => tournament_day, :tournament => tournament, :other_scorecards => other_scorecards}
    end
    
  end
end