module Scoreable
  extend ActiveSupport::Concern

  def player_score(user)
    return nil if !self.includes_player?(user)

    total_score = 0

    scorecard = self.primary_scorecard_for_user(user)
    
    scorecard.scores.each do |score|
      total_score = total_score + score.strokes
    end
    
    return total_score
  end
  
  def primary_scorecard_for_user(user)
    eager_groups = TournamentGroup.includes(teams: [{ golf_outings: :scorecards }]).where(tournament: self)
    
    eager_groups.each do |group|
      group.teams.each do |team|
        team.golf_outings.each do |golf_outing|
          if golf_outing.user == user
            scorecard = golf_outing.scorecards.first

            return scorecard
          end
        end
      end
    end
    
    return nil
  end
  
  def has_scores?
    eager_groups = TournamentGroup.includes(teams: [{ golf_outings: :scorecards }]).where(tournament: self)
    
    eager_groups.each do |group|
      group.teams.each do |team|
        team.golf_outings.each do |golf_outing|
          golf_outing.scorecards.each do |scorecard|
            scorecard.scores.each do |score|
              return true if score.strokes > 0
            end
          end
        end
      end
    end
  end
  
end