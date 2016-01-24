module Presenters
  class ScorecardPresenter
    attr_accessor :primary_scorecard
    attr_accessor :secondary_scorecards
    attr_accessor :shared_data_provider
    
    attr_accessor :all_scorecards
    attr_accessor :user
    attr_accessor :flight
    attr_accessor :course_holes
    attr_accessor :number_of_holes
    attr_accessor :score_count
    attr_accessor :tournament_day
    
    def initialize args      
      args.each do |k,v|
        instance_variable_set("@#{k}", v) unless v.nil?
      end
 
      unless self.secondary_scorecards.blank?
        self.all_scorecards = self.secondary_scorecards.insert(0, self.primary_scorecard)
      else
        self.all_scorecards = [self.primary_scorecard]
      end
      
      self.user = self.primary_scorecard.golf_outing.user
      self.flight = self.primary_scorecard.tournament_day.flight_for_player(self.user)
      self.course_holes = self.primary_scorecard.tournament_day.course_holes
      self.number_of_holes = self.course_holes.count
      self.score_count = self.primary_scorecard.scores.count
      self.tournament_day = self.primary_scorecard.golf_outing.tournament_group.tournament_day
    end
    
    def tee_time
      return self.primary_scorecard.golf_outing.tournament_group.tee_time_at
    end
    
    def tee_names
      return self.primary_scorecard.golf_outing.course_tee_box.name
    end

    def user_can_edit_any_scorecard?(user)
      can_edit_any = false
      
      self.all_scorecards.each do |scorecard|
        return true if self.primary_scorecard.tournament_day.user_can_edit_scorecard(user, scorecard) == true
      end
      
      return can_edit_any
    end
    
    def user_can_edit_scorecard?(user, scorecard)
      return self.primary_scorecard.tournament_day.user_can_edit_scorecard(user, scorecard)
    end
    
    def user_can_become_designated_scorer?(user)      
      return self.tournament_day.user_can_become_designated_scorer(user, self.primary_scorecard)
    end
    
    def designated_scorer
      return self.primary_scorecard.designated_editor
    end
    
    def includes_extra_scoring_column?
      return self.primary_scorecard.includes_extra_scoring_column?
    end
    
    def sliced_scores
      return self.primary_scorecard.scores.each_slice(self.primary_scorecard.tournament_day.course_holes.count / 2).to_a
    end
    
    def scorecard_total_par
      return self.primary_scorecard.tournament_day.course_holes.map {|hole| hole.par }.sum
    end
    
    def scorecard_score_cell_partial
      return self.primary_scorecard.tournament_day.game_type.scorecard_score_cell_partial
    end
    
    def scorecard_post_embed_partial
      return self.primary_scorecard.tournament_day.game_type.scorecard_post_embed_partial
    end
    
    def show_finalization?(user)
      return self.primary_scorecard.has_empty_scores? == false && self.primary_scorecard.tournament_day.user_can_edit_scorecard(user, self.primary_scorecard) == true && self.primary_scorecard.tournament_day.tournament.is_finalized == false
    end
    
  end
end