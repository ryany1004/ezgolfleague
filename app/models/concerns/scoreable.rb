module Scoreable
  extend ActiveSupport::Concern
  
  def handicap_allowance(user)
    golf_outing = self.golf_outing_for_player(user)
    course_handicap = user.course_handicap(self.course, golf_outing.course_tee_box)
    
    if golf_outing.course_tee_box.tee_box_gender == "Men"
      sorted_course_holes_by_handicap = self.course.course_holes.order("mens_handicap")
    else
      sorted_course_holes_by_handicap = self.course.course_holes.order("womens_handicap")
    end
        
    if !course_handicap.blank?    
      allowance = []
      while course_handicap > 0 do
        sorted_course_holes_by_handicap.each do |hole|
          existing_hole = nil
          
          allowance.each do |a|
            if hole == a[:course_hole]
              existing_hole = a
            end
          end
                    
          if existing_hole.blank?            
            existing_hole = {course_hole: hole, strokes: 0}
            allowance << existing_hole
          end
                    
          if course_handicap > 0
            existing_hole[:strokes] = existing_hole[:strokes] + 1
            course_handicap = course_handicap - 1
          end
        end
      end
      
      return allowance
    else
      return nil
    end
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
  
  def user_can_edit_scorecard(user, scorecard)
    return false if self.is_past?
    return false if self.is_finalized == true
    
    return true if scorecard.golf_outing.user == user
    return true if scorecard.designated_editor == user
        
    return false
  end
  
  def user_can_become_designated_scorer(user, scorecard)
    return false if !scorecard.designated_editor.blank?
          
    group = scorecard.golf_outing.team.tournament_group
    return true if self.user_is_in_group?(user, group)
    
    return false
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
    
    return false
  end

end