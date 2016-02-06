module Addable
  extend ActiveSupport::Concern

  def add_player_to_group(tournament_group, user, paying_with_credit_card = false, confirmed = true)
    Tournament.transaction do
      Rails.logger.debug { "Adding to Group" }
      
      outing = GolfOuting.create!(tournament_group: tournament_group, user: user, confirmed: confirmed)
      scorecard = Scorecard.create!(golf_outing: outing)

      Rails.logger.debug { "Added to Group" }

      self.assign_players_to_flights      
      flight = self.flight_for_player(user)
      raise "No Flight for Player #{user.id} (#{user.complete_name})" if flight.blank?

      outing.course_tee_box = flight.course_tee_box
      outing.save
      
      Rails.logger.debug { "Outing Saved" }
    
      self.course_holes.each_with_index do |hole, i|
        score = Score.create!(scorecard: scorecard, course_hole: hole, sort_order: i)
      end
    
      self.add_player_to_free_contests(user)
    
      if self == self.tournament.first_day
        Payment.create(tournament: self.tournament, payment_amount: self.tournament.dues_for_user(user, paying_with_credit_card) * -1.0, user: user, payment_source: "Tournament Dues")
      end
    
      self.automatically_build_teams
    end 
  end

  def automatically_build_teams
    if self.game_type.show_teams? && self.admin_has_customized_teams == false && self.has_scores? == false
      logger.info { "Updating Custom Teams for Tournament Group Save" }
    
      self.golfer_teams.destroy_all

      self.tournament_groups.each do |group|
        if group.players_signed_up.count > 0
          golfer_team = GolferTeam.create(tournament_day: self, max_players: self.game_type.number_of_players_per_team)
      
          group.players_signed_up.each do |player|
            golfer_team.users << player
          end
        end
      end
    else
      logger.info { "Tournament is Not Eligible for Automatic Teams" }
    end
  end

  def remove_player_from_group(tournament_group, user, remove_from_teams = false)
    Tournament.transaction do    
      tournament_group.golf_outings.each do |outing|
        Rails.cache.write(tournament_group.tournament_day.scorecard_id_cache_key(outing.user), nil)
        
        if user.id == outing.scorecard.designated_editor_id
          outing.scorecard.designated_editor_id = nil
          outing.scorecard.save
        end
    
        if outing.user == user
          outing.destroy
          break
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
        c.remove_user(user)
      end
    
      #credit
      if self == self.tournament.first_day
        previous_payments = Payment.where(user: user, tournament: self.tournament).where("payment_amount < 0")
        previous_unrefunded_payments = previous_payments.select{|item| item.credits.count == 0}
        total_unrefunded_payment_amount = previous_unrefunded_payments.map(&:payment_amount).sum

        Rails.logger.debug { "Unrefunded Amount: #{total_unrefunded_payment_amount} From # of Transactions: #{previous_unrefunded_payments.count}" }

        refund = Payment.create(tournament: self.tournament, payment_amount: total_unrefunded_payment_amount * -1.0, user: user, payment_source: "Tournament Dues Credit")
        
        previous_unrefunded_payments.each do |p|
          p.credits << refund
          p.save
        end
      end
    
      #remove from golfer team
      self.automatically_build_teams
    end
  end
  
  def add_player_to_free_contests(user)
    self.contests.each do |c|
      if c.dues_for_user(user).blank? or c.dues_for_user(user) == 0
        c.add_user(user)
      end
    end
  end

  def player_can_be_flighted(user)
    any_flight_possible = false
    
    self.flights.each do |f|
      player_course_handicap = user.course_handicap(self.course, f.course_tee_box)
      
      if player_course_handicap >= f.lower_bound && player_course_handicap <= f.upper_bound
        any_flight_possible = true
      end
    end
    
    return any_flight_possible
  end

  def player_course_handicap_for_player(p, f = nil)
    golf_outing = self.golf_outing_for_player(p) #in multi-day with manual registration, might not match
    unless golf_outing.blank?
      golf_outing.scorecard.set_course_handicap(true) if self.golf_outing_for_player(p).course_handicap == 0 #re-calc handicap if we do not have one
      player_course_handicap = self.golf_outing_for_player(p).course_handicap

      unless f.blank?
        if self.golf_outing_for_player(p).course_handicap == 0 #re-calc handicap if we do not have one
          Rails.logger.debug { "Re-Calculating Course Handicap AGAIN for #{p.complete_name}" }
          
          golf_outing.scorecard.set_course_handicap(true) unless golf_outing.scorecard.blank?

          player_course_handicap = p.course_handicap(self.course, f.course_tee_box)
          
          golf_outing.course_handicap = player_course_handicap
          golf_outing.save
        end
      else
        Rails.logger.debug { "Not Setting Course Handicap - Player Not Flighted #{p.complete_name}" }
      end
 
      Rails.logger.debug { "Player Course Handicap for Course/Outing: #{player_course_handicap}" }
    end
    
    return player_course_handicap
  end

  def assign_players_to_flights(confirm_all_flighted = true)
    self.reload
  
    self.flights.each do |f|
      f.users.clear
        
      self.tournament.players_for_day(self).each do |p|
        player_course_handicap = self.player_course_handicap_for_player(p, f)
 
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