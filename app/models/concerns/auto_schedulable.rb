module AutoSchedulable
  extend ActiveSupport::Concern
  
  def schedule_golfers
    previous_day = self.tournament.previous_day_for_day(self)
    return if previous_day.blank?
    
    players_with_scores = []
    self.tournament.players.each do |p|
      players_with_scores << {player: p, net_score: previous_day.player_score(p)}
    end
    
    if self.tournament.auto_schedule_for_multi_day == AutoScheduleType::AUTOMATIC_WORST_FIRST #worst golfer, worst flight
      Rails.logger.debug { "Scheduling Worst to Best" }
      
      players_with_scores.sort! { |x,y| y[:net_score] <=> x[:net_score] }
    elsif self.tournament.auto_schedule_for_multi_day == AutoScheduleType::AUTOMATIC_BEST_FIRST #best golfer, best flight
      Rails.logger.debug { "Scheduling Best to Worst" }

      players_with_scores.sort! { |x,y| x[:net_score] <=> y[:net_score] }
    end
    
    players_with_scores.each do |result|
      Rails.logger.debug { "Result: #{result[:player].complete_name} #{result[:net_score]}" }
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
        
        self.add_player_to_group(slot, player, true)
      end
    end
  end
  
end