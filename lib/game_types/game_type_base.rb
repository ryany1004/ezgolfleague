module GameTypes

  TEAMS_ALLOWED = "Allowed"
  TEAMS_REQUIRED = "Required"
  TEAMS_DISALLOWED = "Disallowed"
  
  VARIABLE = -1

  class GameTypeBase
    include Rails.application.routes.url_helpers
    
    attr_accessor :tournament_day
    
    def self.available_types
      return [GameTypes::IndividualStrokePlay.new, GameTypes::IndividualMatchPlay.new, GameTypes::IndividualModifiedStableford.new, GameTypes::TwoManShamble.new, GameTypes::TwoManScramble.new, GameTypes::FourManScramble.new, GameTypes::TwoManBestBall.new, GameTypes::TwoBestBallsOfFour.new, GameTypes::TwoManComboScrambleBestBall.new]
    end
    
    def display_name
      return nil
    end
    
    def game_type_id
      return nil
    end
    
    def tournament
      return self.tournament_day.tournament
    end
    
    ##Setup
    
    def can_be_played?
      return false
    end
    
    def can_be_finalized?
      return false
    end
    
    def setup_partial
      return nil
    end
    
    def save_setup_details(game_type_options)
      #do nothing
    end
    
    def remove_game_type_options
      #do nothing
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
    
    def after_updating_scores_for_scorecard(scorecard)
      #nada
    end
    
    def related_scorecards_for_user(user)
      return []
    end

    def player_score(user, use_handicap = true, holes = [])
      return nil if !self.tournament.includes_player?(user)

      total_score = 0
    
      handicap_allowance = self.tournament_day.handicap_allowance(user)

      scorecard = self.tournament_day.primary_scorecard_for_user(user)
      return 0 if scorecard.blank?
      
      scorecard.scores.each do |score|
        should_include_score = true #allows us to calculate partial scores, i.e. back 9
        if holes.blank? == false
          should_include_score = false if !holes.include? score.course_hole.hole_number
        end
        
        if should_include_score == true
          hole_score = score.strokes
      
          if use_handicap == true && !handicap_allowance.blank?
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
      end
    
      total_score = 0 if total_score < 0
    
      return total_score
    end
    
    def player_points(user)
      return nil if !self.tournament.includes_player?(user)
    
      points = 0

      self.tournament_day.flights.each do |f|
        f.payouts.each do |p|
          points = points + p.points if p.user == user
        end
      end
      
      #contests
      self.tournament_day.contests.each do |c|
        c.contest_results.each do |r|
          points = points + r.points if r.winner == user
        end
      end
    
      return points
    end
    
    def includes_extra_scoring_column?
      return false
    end
    
    def override_scorecard_name_for_scorecard(scorecard)
      return nil
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
      golf_outing = self.tournament_day.golf_outing_for_player(user)
      return nil if golf_outing.blank? #did not play

      course_handicap = golf_outing.course_handicap
    
      if golf_outing.course_tee_box.tee_box_gender == "Men"
        sorted_course_holes_by_handicap = self.tournament_day.course_holes.reorder("mens_handicap")
      else
        sorted_course_holes_by_handicap = self.tournament_day.course_holes.reorder("womens_handicap")
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
    
      self.tournament_day.flights.each do |f|
        ranked_flight = { flight_id: f.id, flight_number: f.flight_number, players: [] }
      
        f.users.each do |player|          
          net_score = self.player_score(player, true)
          back_nine_net_score = self.player_score(player, true, [10, 11, 12, 13, 14, 15, 16, 17, 18])
          gross_score = self.player_score(player, false)

          Rails.logger.debug { "Looking up Scorecard for #{player.id}" }
          scorecard = self.tournament_day.primary_scorecard_for_user(player)
          scorecard_url = play_scorecard_path(scorecard)

          points = 0
          f.payouts.each do |payout|
            points = payout.points if payout.user == player
          end
      
          ranked_flight[:players] << { id: player.id, name: player.complete_name, net_score: net_score, back_nine_net_score: back_nine_net_score, gross_score: gross_score, scorecard_url: scorecard_url, points: points } if !net_score.blank? && net_score > 0
        end
        
        self.sort_rank_players_in_flight!(ranked_flight[:players])
      
        ranked_flights << ranked_flight
      end

      return ranked_flights
    end
    
    def sort_rank_players_in_flight!(flight_players)
      flight_players.sort! { |x,y| x[:net_score] <=> y[:net_score] }
    end
    
    ##Payouts
    
    def eligible_players_for_payouts
      eligible_player_list = []
      if self.tournament.tournament_days.count == 1
        eligible_player_list = self.tournament.players
      else #only players that play all days can win
        self.tournament.players.each do |player|
          player_played_all_days = true
          
          self.tournament.tournament_days.each do |day|
            player_played_all_days = false if self.tournament.includes_player?(player, day) == false
          end
          
          eligible_player_list << player.id if player_played_all_days == true
        end
      end
      
      eligible_player_list.each do |p|
        Rails.logger.debug { "Eligible: #{p}" }
      end
      
      return eligible_player_list
    end
  
    def assign_payouts_from_scores
      payout_count = 0
      self.tournament_day.flights.each do |flight|
        payout_count += flight.payouts.count
        
        flight.payouts.each do |p|
          p.user = nil
          p.save
        end
      end
      
      return if payout_count == 0

      if self.tournament.tournament_days.count > 1 && self.tournament_day == self.tournament.last_day        
        eligible_player_list = self.eligible_players_for_payouts
      
        rankings = []
        self.tournament.tournament_days.each do |day|
          rankings << day.flights_with_rankings
        end
        
        ranked_flights = self.tournament.combine_rankings(rankings)
      else
        eligible_player_list = self.tournament.players
        
        ranked_flights = self.flights_with_rankings
      end
      
      ##
      Rails.logger.debug { "DEBUG DEBUG DEBUG" }
      ranked_flights.each do |ranked_flight|
        Rails.logger.debug { "Flight: #{ranked_flight[:flight_id]} #{ranked_flight[:flight_number]}" }
        
        ranked_flight[:players].each do |player|
          Rails.logger.debug { "#{player[:id]} #{player[:name]} #{player[:net_score]}" }
        end
      end
      ##

      ranked_flights.each do |flight_ranking|
        flight_ranking[:players].each do |p|
          if eligible_player_list.include? p[:id]
            flight = Flight.find(flight_ranking[:flight_id])
            flight.payouts.each_with_index do |p, i|              
              if flight_ranking[:players].count > i
                player = User.find(flight_ranking[:players][i][:id])
                
                Rails.logger.debug { "Assigning #{player.complete_name} to #{p.id}" }
                
                p.user = player
                p.save!
              end
            end
          else
            Rails.logger.debug { "Player Not Eligible: #{p}" }
          end
        end
      end
    end
    
  end
end