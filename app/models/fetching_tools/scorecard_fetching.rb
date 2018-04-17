module FetchingTools
  class ScorecardFetching
    
    def self.fetch_scorecards_and_related(scorecard_id)
      scorecard = Scorecard.includes(scores: [:course_hole], golf_outing: [:user]).find(scorecard_id)
      tournament_day = scorecard.golf_outing.tournament_group.tournament_day
      tournament = tournament_day.tournament
      
      other_scorecards = []
      scorecards_to_update = []

      if tournament_day.game_type.show_other_scorecards?
        other_scorecards = tournament_day.related_scorecards_for_user(scorecard.golf_outing.user)

        other_scorecards.each do |o|
          scorecards_to_update << o unless o.id == -1
        end
      end

      return {:scorecard => scorecard, :tournament_day => tournament_day, :tournament => tournament, :other_scorecards => other_scorecards, :scorecards_to_update => scorecards_to_update}
    end
    
  end
end