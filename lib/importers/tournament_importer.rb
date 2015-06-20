require 'smarter_csv'

module Importers
  class TournamentImporter
    attr_accessor :flight_code_flight_mapping
    attr_accessor :tee_group_code_tee_group_mapping
    
    def import(filename)
      Tournament.uncached do
        self.flight_code_flight_mapping = {}
        self.tee_group_code_tee_group_mapping = {}
      
        tournament_lines = SmarterCSV.process(filename)
      
        Rails.logger.debug { "Number of Lines: #{tournament_lines.count}" }
        
        #clear old data
        tournament_lines.each do |line|
          tournament = Tournament.where(id: line[:tournament_id]).first
          tournament.tournament_groups.destroy_all
          tournament.flights.destroy_all
        end
      
        tournament_lines.each do |line|
          #tournament
          tournament = Tournament.where(id: line[:tournament_id]).first
          raise "Missing Tournament" if tournament.blank?

          course_tee_box = tournament.course.course_tee_boxes.where(name: line[:course_tee_box_name]).first
          raise "Missing Course Tee Box" if course_tee_box.blank?

          #player
          player = self.find_or_create_player_in_league(line[:player_last_name], line[:player_first_name], line[:course_handicap], course_tee_box.rating, tournament.league)
          raise "No Player" if player.blank?
        
          #flights
          self.create_or_add_player_to_flight(player, line[:flight], tournament, course_tee_box)
        
          #tee_group
          self.create_or_add_player_to_tee_group(player, line[:tee_group], line[:tee_time], tournament)
        
          #payouts  
          self.create_or_add_payouts_for_player(player, line[:payout_dollars], line[:payout_points], tournament) unless line[:payout_dollars].blank?

          #strokes
          course_hole_scores = []
          course_hole_scores << {hole_name: "1", score: line[:h1]}
          course_hole_scores << {hole_name: "2", score: line[:h2]}
          course_hole_scores << {hole_name: "3", score: line[:h3]}
          course_hole_scores << {hole_name: "4", score: line[:h4]}
          course_hole_scores << {hole_name: "5", score: line[:h5]}
          course_hole_scores << {hole_name: "6", score: line[:h6]}
          course_hole_scores << {hole_name: "7", score: line[:h7]}
          course_hole_scores << {hole_name: "8", score: line[:h8]}
          course_hole_scores << {hole_name: "9", score: line[:h9]}
          course_hole_scores << {hole_name: "10", score: line[:h10]}
          course_hole_scores << {hole_name: "11", score: line[:h11]}
          course_hole_scores << {hole_name: "12", score: line[:h12]}
          course_hole_scores << {hole_name: "13", score: line[:h13]}
          course_hole_scores << {hole_name: "14", score: line[:h14]}
          course_hole_scores << {hole_name: "15", score: line[:h15]}
          course_hole_scores << {hole_name: "16", score: line[:h16]}
          course_hole_scores << {hole_name: "17", score: line[:h17]}
          course_hole_scores << {hole_name: "18", score: line[:h18]}
        
          self.assign_scores(player, course_hole_scores, tournament)
        end
      end
    end
    
    def find_or_create_player_in_league(last_name, first_name, course_handicap, rating, league)      
      player = league.users.where("last_name = ? AND first_name = ?", last_name, first_name).first
      
      if course_handicap > 0
        handicap_index = (course_handicap / (rating / 113.0)).round
      else
        handicap_index = 0
      end
      
      if player.blank?        
        player = User.create!(first_name: first_name, last_name: last_name, password: "imported_user", email: "#{Time.now.to_i}-#{Random.rand(1000)}@imported.com", handicap_index: handicap_index)
        player.leagues << league
      else
        player.handicap_index = handicap_index
        player.save
      end
      
      return player
    end
    
    def create_or_add_player_to_flight(player, flight_code, tournament, course_tee_box)      
      flight = self.flight_code_flight_mapping[flight_code]
      if flight.blank?
        last_flight = tournament.flights.last
        if last_flight.blank?
          flight_number = 1
        else
          flight_number = last_flight.flight_number + 1
        end

        flight = Flight.create!(tournament: tournament, flight_number: flight_number, course_tee_box: course_tee_box, lower_bound: -1, upper_bound: -1)
      end
      
      flight.users << player
      
      self.flight_code_flight_mapping[flight_code] = flight
    end
    
    def create_or_add_player_to_tee_group(player, tee_group_code, tee_time, tournament)    
      tournament_group = self.tee_group_code_tee_group_mapping[tee_group_code]
      if tournament_group.blank?
        tee_time_string = "#{tournament.tournament_at.to_s(:short_year)} #{tee_time}"
        parsed_tee_time = DateTime.strptime("#{tee_time_string} #{Time.zone.now.formatted_offset}", JAVASCRIPT_DATETIME_PICKER_FORMAT)
        raise "No Tee Time" if parsed_tee_time.blank?
                
        tournament_group = TournamentGroup.create(tournament: tournament, tee_time_at: parsed_tee_time)
      end

      flight = nil
      tournament.flights.each do |f|
        flight = f if f.users.include? player
      end
      raise "No Flight for Player #{player.id} (#{player.complete_name})" if flight.blank?

      team = Team.create!(tournament_group: tournament_group)
      outing = GolfOuting.create!(team: team, user: player, confirmed: true, course_tee_box: flight.course_tee_box)
      scorecard = Scorecard.create!(golf_outing: outing)
    
      tournament.course_holes.each_with_index do |hole, i|
        score = Score.create!(scorecard: scorecard, course_hole: hole, sort_order: i)
      end
      
      self.tee_group_code_tee_group_mapping[tee_group_code] = tournament_group
    end
    
    def create_or_add_payouts_for_player(player, payout_dollars, payout_points, tournament)
      flight = tournament.flight_for_player(player)
      raise "No Flight" if flight.blank?
      
      payout = Payout.create(flight: flight, user: player, amount: payout_dollars, points: payout_points)
    end

    def assign_scores(player, course_hole_scores, tournament)
      scorecard = tournament.primary_scorecard_for_user(player)
      raise "No Scorecard" if scorecard.blank?
      
      course_hole_scores.each do |course_hole_score|
        course_hole = tournament.course.course_holes.where(hole_number: course_hole_score[:hole_name])
        raise "No Course Hole" if course_hole.blank?
        
        score = scorecard.scores.where(course_hole: course_hole).first
        raise "No Score" if score.blank?
        
        score.strokes = course_hole_score[:score]
        score.save
      end
    end

  end
end