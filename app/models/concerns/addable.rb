module Addable
  extend ActiveSupport::Concern

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
    
      self.add_player_to_free_contests(user)
    
      if self == self.tournament.first_day
        Payment.create(tournament: self.tournament, payment_amount: self.tournament.dues_amount * -1.0, user: user, payment_source: "Tournament Dues")
      end
    
      self.automatically_build_teams
    end 
  end

  def automatically_build_teams
    if self.game_type.show_teams? && self.admin_has_customized_teams == false && self.has_scores? == false
      logger.info { "Updating Custom Teams for Tournament Group Save" }
    
      self.golfer_teams.destroy_all
    
      self.tournament_groups.each do |group|
        golfer_team = GolferTeam.create(tournament_day: self, max_players: group.max_number_of_players)
      
        group.players_signed_up.each do |player|
          golfer_team.users << player
        end
      end
    else
      logger.info { "Tournament is Not Eligible for Automatic Teams" }
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
      
      #remove from flight
      flight = self.flight_for_player(user)
      flight.users.delete(user) unless flight.blank?
  
      #remove from teams
      if remove_from_teams == true
        self.golfer_teams.each do |team|
          if team.users.include? user
            team.users.destroy(user)
          end
        end
      end
      
      #contests
      self.contests.each do |c|
        c.users.destroy(user) if c.users.include? user
      end
    
      #credit
      if self == self.tournament.first_day
        Payment.create(tournament: self.tournament, payment_amount: self.tournament.dues_amount, user: user, payment_source: "Tournament Dues Credit")
      end
    
      #remove from golfer team
      self.automatically_build_teams
    end
  end
  
  def add_player_to_free_contests(user)
    self.contests.each do |c|
      if c.dues_amount.blank? or c.dues_amount == 0
        c.users << user
      end
    end
  end

  def assign_players_to_flights(confirm_all_flighted = true)
    self.reload
  
    self.flights.each do |f|
      f.users.clear
        
      self.tournament.players_for_day(self).each do |p|
        golf_outing = self.golf_outing_for_player(p) #in multi-day with manual registration, might not match
        unless golf_outing.blank?
          golf_outing.scorecards.first.set_course_handicap(true) if self.golf_outing_for_player(p).course_handicap == 0 #re-calc handicap if we do not have one
          player_course_handicap = self.golf_outing_for_player(p).course_handicap

          if self.golf_outing_for_player(p).course_handicap == 0 #re-calc handicap if we do not have one
            golf_outing.scorecards.first.set_course_handicap(true) unless golf_outing.scorecards.blank?
            
            player_course_handicap = p.course_handicap(self.course, f.course_tee_box)
          end
          
          Rails.logger.debug { "Player Course Handicap for Course/Outing: #{player_course_handicap}" }
        end
 
        unless player_course_handicap.blank?
          if player_course_handicap >= f.lower_bound && player_course_handicap <= f.upper_bound            
            f.users << p
            
            Rails.logger.debug { "Flighted: #{player_course_handicap} (#{f.lower_bound} to #{f.upper_bound}) for Player: #{p.id} #{p.complete_name} for Flight Num #{f.flight_number}" }
          else
            Rails.logger.debug { "NOT Flighted: #{player_course_handicap} (#{f.lower_bound} to #{f.upper_bound}) for Player: #{p.id} #{p.complete_name} for Flight Num #{f.flight_number}" }
          end
        else
          Rails.logger.debug { "Player Course Handicap Blank: #{p.id} #{p.complete_name}" }
        end
      end
    end
  
    self.touch #bust the cache, yo.
  
    #TODO: convert this to a validation error or something? just blowing up seems bad.
    if confirm_all_flighted == true && self.flights.count > 0
      self.tournament.players_for_day(self).each do |p|
        if self.flight_for_player(p) == nil
          player_course_handicap = self.golf_outing_for_player(p).course_handicap unless self.golf_outing_for_player(p).blank?
          error_massage_is_comfy = "Player Not Flighted: #{p.id} in Tournament #{self.id} | Index: #{player_course_handicap}"
        
          self.flights.each do |f|
            error_massage_is_comfy += "| #{f.lower_bound} / #{f.upper_bound} |"
          end
        
          raise error_massage_is_comfy
        end
      end
    end
  end

end