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
  
  def score_users
    self.tournament.players.each do |player|
      self.score_user(player)
    end
  end
  
  def score_user(user)
    existing_result = self.tournament_day_results.where(user: user).first
    existing_result.destroy unless existing_result.blank?
    
    primary_scorecard = self.primary_scorecard_for_user(user)
    
    net_score = self.compute_player_score(user, true)
    front_nine_net_score = self.compute_player_score(user, true, [1, 2, 3, 4, 5, 6, 7, 8, 9])
    back_nine_net_score = self.compute_player_score(user, true, [10, 11, 12, 13, 14, 15, 16, 17, 18])
    gross_score = self.compute_player_score(user, false)
    
    result = TournamentDayResult.create(tournament_day: self, user: user, primary_scorecard: primary_scorecard, flight: self.flight_for_player(user), gross_score: gross_score, net_score: net_score, front_nine_net_score: front_nine_net_score, back_nine_net_score: back_nine_net_score)
    
    return result
  end

end