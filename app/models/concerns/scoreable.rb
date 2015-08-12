module Scoreable
  extend ActiveSupport::Concern
  
  def primary_scorecard_for_user(user)
    eager_groups = TournamentGroup.includes(teams: [{ golf_outings: :scorecards }]).where(tournament_day: self)
    
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
  
  def user_can_edit_scorecard(user, scorecard)
    return false if self.tournament.is_past?
    return false if self.tournament.is_finalized == true
    return false if scorecard.is_potentially_editable? == false
    
    return true if scorecard.golf_outing.user == user
    return true if scorecard.designated_editor == user
    
    #check if they are on a team together
    team = scorecard.tournament_day.golfer_team_for_player(user)
    unless team.blank?
      team.users.each do |u|
        if u == user and team.users.include? scorecard.golf_outing.user
          return true
        end
      end
    end
    
    return false
  end
  
  def user_can_become_designated_scorer(user, scorecard)
    return false if !scorecard.designated_editor.blank?
          
    group = scorecard.golf_outing.team.tournament_group
    return true if self.user_is_in_group?(user, group)
    
    return false
  end
  
  def has_scores?    
    eager_groups = TournamentGroup.includes(teams: [{ golf_outings: :scorecards }]).where(tournament_day: self)
    
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
    
    return false
  end

end