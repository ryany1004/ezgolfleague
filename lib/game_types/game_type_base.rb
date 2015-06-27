module GameTypes

  TEAMS_ALLOWED = "Allowed"
  TEAMS_REQUIRED = "Required"
  TEAMS_DISALLOWED = "Disallowed"
  
  VARIABLE = -1

  class GameTypeBase
    include Rails.application.routes.url_helpers
    
    attr_accessor :tournament
    
    def self.available_types
      return [GameTypes::IndividualStrokePlay.new, GameTypes::IndividualMatchPlay.new, GameTypes::IndividualModifiedStableford.new, GameTypes::TwoManShamble.new, GameTypes::TwoManScramble.new, GameTypes::FourManScramble.new, GameTypes::TwoManBestBall.new, GameTypes::TwoBestBallsOfFour.new, GameTypes::TwoManComboScrambleBestBall.new]
    end
    
    def display_name
      return nil
    end
    
    def game_type_id
      return nil
    end
    
    ##Setup
    
    def can_be_played?
      return false
    end
    
    def can_be_finalized?
      return false
    end
    
    ##Group
    
    def other_group_members(user)
      return nil
    end
    
    def user_is_in_group?(user, tournament_group)
      return false
    end
    
    ##Teams
    
    def allow_teams
      return GameTypes::TEAMS_DISALLOWED
    end
    
    def show_teams?
      return false
    end
    
    def number_of_players_per_team
      return 0
    end
    
    def players_create_teams?
      return true
    end
    
    def show_team_scores_for_all_teammates?
      return true
    end
    
    def team_players_are_opponents?
      return false
    end
    
    ##Scoring
    
    def related_scorecards_for_user(user)
      return []
    end

    def player_score(user, use_handicap = true)
      return nil if !self.tournament.includes_player?(user)

      total_score = 0
    
      handicap_allowance = self.tournament.handicap_allowance(user)

      scorecard = self.tournament.primary_scorecard_for_user(user)
      scorecard.scores.each do |score|
        hole_score = score.strokes
      
        if use_handicap == true
          handicap_allowance.each do |h|
            if h[:course_hole] == score.course_hole
              if h[:strokes] != 0
                hole_score = hole_score - h[:strokes]
              end
            end
          end
        end

        total_score = total_score + hole_score
      end
    
      total_score = 0 if total_score < 0
    
      return total_score
    end
    
    def player_points(user)
      return nil if !self.tournament.includes_player?(user)
    
      points = 0
    
      #payouts
      self.tournament.flights.each do |f|
        f.payouts.each do |p|
          points = points + p.points if p.user == user
        end
      end
      
      #contests
      self.tournament.contests.each do |c|
        c.contest_results.each do |r|
          points = points + r.points if r.winner == user
        end
      end
    
      return points
    end
    
    def includes_extra_scoring_column?
      return false
    end
    
    ##Metadata
    
    def update_metadata(metadata)
      #do nothing
    end
    
    ##UI
    
    def scorecard_score_cell_partial
      return nil
    end
    
    def scorecard_post_embed_partial
      return nil
    end

    def associated_text_for_score(score)
      return nil
    end

    ##Handicap
    
    def handicap_allowance(user)
      golf_outing = self.tournament.golf_outing_for_player(user)
      course_handicap = golf_outing.course_handicap
    
      if golf_outing.course_tee_box.tee_box_gender == "Men"
        sorted_course_holes_by_handicap = self.tournament.course.course_holes.order("mens_handicap")
      else
        sorted_course_holes_by_handicap = self.tournament.course.course_holes.order("womens_handicap")
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
    
    ##Ranking

    def flights_with_rankings
      ranked_flights = []
    
      self.tournament.flights.each do |f|
        ranked_flight = { flight_id: f.id, flight_number: f.flight_number, players: [] }
      
        f.users.each do |player|
          net_score = self.player_score(player, true)
          gross_score = self.player_score(player, false)
          
          scorecard = self.tournament.primary_scorecard_for_user(player)
          scorecard_url = play_scorecard_path(scorecard)
        
          points = 0
          f.payouts.each do |payout|
            points = payout.points if payout.user == player
          end
      
          ranked_flight[:players] << { id: player.id, name: player.complete_name, net_score: net_score, gross_score: gross_score, scorecard_url: scorecard_url, points: points } if !net_score.blank? && net_score > 0
        end
        ranked_flight[:players].sort! { |x,y| x[:net_score] <=> y[:net_score] }
      
        ranked_flights << ranked_flight
      end
    
      return ranked_flights
    end
    
    ##Payouts
    
    def assign_payouts_from_scores
      self.tournament.flights.each do |f|
        player_scores = []
      
        f.users.each do |player|
          score = self.player_score(player)
      
          player_scores << {player: player, score: score}
        end
      
        player_scores.sort! { |x,y| x[:score] <=> y[:score] }
            
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

end

