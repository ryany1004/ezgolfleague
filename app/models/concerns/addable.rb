module Addable
  extend ActiveSupport::Concern

  def is_open_for_registration?
    return false if self.number_of_players >= self.max_players
    return false if self.signup_opens_at > Time.zone.now
    
    return true
  end

  def add_player_to_group(tournament_group, user, course_tee_box, confirmed = true)
    Tournament.transaction do
      team = Team.create!(tournament_group: tournament_group)
      outing = GolfOuting.create!(team: team, user: user, course_tee_box: course_tee_box, confirmed: confirmed)
      scorecard = Scorecard.create!(golf_outing: outing)
      
      self.course_holes.each_with_index do |hole, i|
        score = Score.create!(scorecard: scorecard, course_hole: hole, sort_order: i)
      end
    end
  end
  
  def remove_player_from_group(tournament_group, user)
    tournament_group.teams.each do |team|
      team.golf_outings.each do |outing|
        if outing.user == user
          outing.destroy
          team.destroy if team.golf_outings.count == 0
          break
        end
      end
    end
  end

  def assign_players_to_flights
    self.flights.each do |f|  
      f.users.clear
          
      self.players.each do |p|    
        golf_outing = self.golf_outing_for_player(p)
        player_course_handicap = p.course_handicap(self.course, golf_outing.course_tee_box)
        
        unless player_course_handicap.blank?
          if player_course_handicap >= f.lower_bound && player_course_handicap <= f.upper_bound
            f.users << p
          end
        end
      end
    end
    
    self.players.each do |p|
      raise "Player Not Flighted: #{p.id} in Tournament #{self.id}" if self.flight_for_player(p) == nil
    end
  end 

end