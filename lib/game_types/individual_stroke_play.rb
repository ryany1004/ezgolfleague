module GameTypes
  class IndividualStrokePlay < GameTypes::GameTypeBase

    def display_name
      return "Individual Stroke Play"
    end
    
    def game_type_id
      return 1
    end

    def player_score(user)
      return nil if !self.tournament.includes_player?(user)

      total_score = 0
    
      handicap_allowance = self.tournament.handicap_allowance(user)

      scorecard = self.tournament.primary_scorecard_for_user(user)
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

  end
end