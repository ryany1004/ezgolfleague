module Addable
  extend ActiveSupport::Concern

  def is_open_for_registration?
    return false if self.number_of_players >= self.max_players
    return false if self.signup_opens_at > Time.zone.now
    return false if self.flights.count == 0
    
    return true
  end

  def add_player_to_group(tournament_group, user, confirmed = true)
    Tournament.transaction do
      team = Team.create!(tournament_group: tournament_group)
      outing = GolfOuting.create!(team: team, user: user, confirmed: confirmed)
      scorecard = Scorecard.create!(golf_outing: outing)

      self.assign_players_to_flights      
      flight = self.flight_for_player(user)
      raise "No Flight for Player #{user.id} (#{user.complete_name})" if flight.blank?

      outing.course_tee_box = flight.course_tee_box
      outing.save
      
      self.course_holes.each_with_index do |hole, i|
        score = Score.create!(scorecard: scorecard, course_hole: hole, sort_order: i)
      end
    end 
  end
  
  def remove_player_from_group(tournament_group, user, remove_from_teams = false)
    Tournament.transaction do    
      tournament_group.teams.each do |team|
        team.golf_outings.each do |outing|
          outing.scorecards.each do |scorecard|
            if user.id == scorecard.designated_editor_id
              scorecard.designated_editor_id = nil
              scorecard.save
            end
          end
        
          if outing.user == user
            outing.destroy
            team.destroy if team.golf_outings.count == 0
          
            break
          end
        end
      end
    
      #remove from teams
      if remove_from_teams == true
        self.golfer_teams.each do |team|
          if team.users.include? user
            team.users.destroy(user)
          end
        end
      end
    end
  end

  def assign_players_to_flights(confirm_all_flighted = true)
    self.reload
    
    self.flights.each do |f|
      f.users.clear
          
      self.players.each do |p|            
        player_course_handicap = p.course_handicap(self.course, f.course_tee_box)
                
        unless player_course_handicap.blank?
          if player_course_handicap >= f.lower_bound && player_course_handicap <= f.upper_bound            
            f.users << p
          end
        else
          Rails.logger.debug { "Player Course Handicap Blank: #{p.id}" }
        end
      end
    end
    
    if confirm_all_flighted == true          
      self.players.each do |p|
        if self.flight_for_player(p) == nil          
          error_massage_is_comfy = "Player Not Flighted: #{p.id} in Tournament #{self.id} | Index: #{p.handicap_index}"
          
          self.flights.each do |f|
            error_massage_is_comfy += "| #{f.lower_bound} / #{f.upper_bound} |"
          end
          
          raise error_massage_is_comfy
        end
      end
    end
  end 

end