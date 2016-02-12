module Scoreable
  extend ActiveSupport::Concern
  
  def scorecard_id_cache_key(user)
    return "#{self.id}-#{user.id}"
  end
  
  def primary_scorecard_for_user(user)
    cache_key = self.scorecard_id_cache_key(user)
    scorecard_id = Rails.cache.fetch(cache_key)
    
    if scorecard_id.blank?
      eager_groups = TournamentGroup.includes(golf_outings: [{scorecard: :scores}, :user]).where(tournament_day: self)
    
      eager_groups.each do |group|
        golf_outing = group.golf_outings.where(user: user).first
        
        unless golf_outing.blank?
          scorecard = golf_outing.scorecard
        
          Rails.cache.write(cache_key, scorecard.id)
        
          return scorecard
        end
      end
    else      
      return Scorecard.where(id: scorecard_id).first
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
        return true if u == user and team.users.include? scorecard.golf_outing.user
      end
    end
    
    return false
  end
  
  def user_can_become_designated_scorer(user, scorecard)
    return false if !scorecard.designated_editor.blank?
          
    group = scorecard.golf_outing.tournament_group
    return true if self.user_is_in_group?(user, group)
    
    return false
  end
  
  def has_scores?
    eager_groups = TournamentGroup.includes(golf_outings: [{scorecard: :scores}, :user]).where(tournament_day: self)
    
    eager_groups.each do |group|
      group.golf_outings.each do |golf_outing|
        golf_outing.scorecard.scores.each do |score|
          return true if score.strokes > 0
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
    self.tournament_day_results.where(user: user).destroy_all
    
    primary_scorecard = self.primary_scorecard_for_user(user)
    flight = self.flight_for_player(user)
    
    net_score = self.compute_player_score(user, true)
    gross_score = self.compute_player_score(user, false)
    adjusted_score = self.compute_adjusted_player_score(user)
    
    front_nine_gross_score = self.compute_player_score(user, false, [1, 2, 3, 4, 5, 6, 7, 8, 9])
    front_nine_net_score = self.compute_player_score(user, true, [1, 2, 3, 4, 5, 6, 7, 8, 9])
    back_nine_net_score = self.compute_player_score(user, true, [10, 11, 12, 13, 14, 15, 16, 17, 18])

    user_par = self.user_par_for_played_holes(user)
    par_related_net_score = net_score - user_par
    par_related_gross_score = gross_score - user_par

    result = TournamentDayResult.create(tournament_day: self, user: user, primary_scorecard: primary_scorecard, flight: flight, gross_score: gross_score, net_score: net_score, adjusted_score: adjusted_score, front_nine_gross_score: front_nine_gross_score, front_nine_net_score: front_nine_net_score, back_nine_net_score: back_nine_net_score, par_related_net_score: par_related_net_score, par_related_gross_score: par_related_gross_score)
    
    return result
  end
  
  def user_par_for_played_holes(user)
    par = 0
    
    primary_scorecard = self.primary_scorecard_for_user(user)
    return 0 if primary_scorecard.blank?
        
    primary_scorecard.scores.each do |s|
      if s.strokes > 0
        par_adjustment = s.course_hole.par
        
        par = par + par_adjustment
      end
    end

    Rails.logger.debug { "User Par: #{par}" }

    return par
  end

end