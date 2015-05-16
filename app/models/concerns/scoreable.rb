module Scoreable
  extend ActiveSupport::Concern

  def player_score(user)
    return nil if !self.includes_player?(user)

    total_score = 0
    
    handicap_allowance = self.handicap_allowance(user)

    scorecard = self.primary_scorecard_for_user(user)
    
    scorecard.scores.each do |score|
      hole_score = score.strokes
      
      handicap_allowance.each do |h|
        if h[:course_hole] == score.course_hole
          if h[:strokes] != 0
            hole_score = hole_score - h[:strokes]
          end
        end
      end
      
      total_score = total_score + hole_score
    end
    
    return total_score
  end
  
  def player_points(user)
    return nil if !self.includes_player?(user)
    
    points = 0
    
    self.flights.each do |f|
      f.payouts.each do |p|
        points = points + p.points if p.user == user
      end
    end
    
    return points
  end
  
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

  def assign_payouts_from_scores
    self.flights.each do |f|
      player_scores = []
      
      f.users.each do |player|
        score = self.player_score(player)
      
        player_scores << {player: player, score: score}
      end
      
      player_scores.sort! { |x,y| x[:score] <=> y[:score] }
      
      Rails.logger.debug { "Flights: #{self.flights.count} | Users: #{f.users.count} | PS: #{player_scores.count} | Payouts: #{f.payouts.count}" }
      
      f.payouts.each_with_index do |p, i|
        if player_scores.count > i
          player = player_scores[i][:player]
        
          p.user = player
          p.save
        end
      end
      
    end
  end

end