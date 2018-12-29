module FetchingTools
  class ScorecardFetching
    def self.fetch_scorecards_and_related(scorecard_id)
      scorecard = Scorecard.includes(scores: [:course_hole], golf_outing: [:user]).find(scorecard_id)
      tournament_day = scorecard.golf_outing.tournament_group.tournament_day
      tournament = tournament_day.tournament
      
      other_scorecards = []
      scorecards_to_update = []

      tournament_day.scoring_rules.each do |rule|
        if rule.show_other_scorecards?
          other_scorecards = rule.related_scorecards_for_user(scorecard.golf_outing.user) if other_scorecards.count == 0

          other_scorecards.each do |o|
            if (o.id != -1) && !(scorecards_to_update.include? o)
              scorecards_to_update << o
            end
          end
        end
      end

      { scorecard: scorecard, tournament_day: tournament_day, tournament: tournament, other_scorecards: other_scorecards, scorecards_to_update: scorecards_to_update }
    end
  end
end