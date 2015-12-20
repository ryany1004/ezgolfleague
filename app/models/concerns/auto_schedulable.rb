module AutoSchedulable
  extend ActiveSupport::Concern
  
  def schedule_golfers
    previous_day = self.tournament.previous_day_for_day(self)
    return if previous_day.blank?
        
    players_with_scores = []
    self.tournament.players.each do |p|
      flight = previous_day.flight_for_player(p)
      
      players_with_scores << {player: p, flight_number: flight.flight_number, net_score: previous_day.player_score(p)} unless flight.blank?
    end
    
    if self.tournament.auto_schedule_for_multi_day == AutoScheduleType::AUTOMATIC_WORST_FIRST #worst golfer, worst flight
      Rails.logger.debug { "Scheduling #{players_with_scores.count} Golfers Worst to Best" }

      players_with_scores.sort! { |x,y| [y[:flight_number], y[:net_score]] <=> [x[:flight_number], x[:net_score]] }
    elsif self.tournament.auto_schedule_for_multi_day == AutoScheduleType::AUTOMATIC_BEST_FIRST #best golfer, best flight
      Rails.logger.debug { "Scheduling #{players_with_scores.count} Golfers Best to Worst" }

      players_with_scores.sort! { |x,y| [x[:flight_number], x[:net_score]] <=> [y[:flight_number], y[:net_score]] }
    end
    
    players_with_scores.each do |result|
      Rails.logger.debug { "Result: #{result[:player].complete_name} #{result[:net_score]} F: #{result[:flight_number]}" }
    end
    
    group_slots = []
    self.tournament_groups.each do |group|
      group.max_number_of_players.times do
        group_slots << group
      end 
    end
    
    players_with_scores.each_with_index do |player_score, index|
      player = player_score[:player]
    
      if group_slots.count > index
        slot = group_slots[index]
        
        existing_group = self.tournament_group_for_player(player)
        self.remove_player_from_group(existing_group, player, true) unless existing_group.blank?
        
        self.add_player_to_group(slot, player, false, true)
      end
    end
  end
  
end