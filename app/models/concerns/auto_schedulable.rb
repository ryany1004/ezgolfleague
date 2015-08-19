module AutoSchedulable
  extend ActiveSupport::Concern

  def schedule_golfers
    if self.tournament.auto_schedule_for_multi_day == AutoScheduleType::AUTOMATIC_WORST_FIRST #worst golfer, worst flight
      #sort players worst to best
    elsif self.tournament.auto_schedule_for_multi_day == AutoScheduleType::AUTOMATIC_BEST_FIRST #best golfer, best flight
      #sort players best to worst
    end
    
    unless players.blank?
      self.tournament_groups.each_with_index do |group, index|
        if players.count > index
          player = players[index]
          
          self.add_player_to_group(group, player, true)
        end
      end
    end
  end
  
end