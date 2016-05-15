module AutoSchedulable
  extend ActiveSupport::Concern

  def schedule_golfers
    previous_day = self.tournament.previous_day_for_day(self)
    return if previous_day.blank?

    players_with_scores = []
    self.tournament.players.each do |p|
      self.tournament.tournament_days.first.assign_players_to_flights

      flight = previous_day.flight_for_player(p)
      group = previous_day.tournament_group_for_player(p)

      unless flight.blank?
        players_with_scores << {player: p, flight_number: flight.flight_number, net_score: previous_day.player_score(p), previous_day_group_id: group.id}
      else
        Rails.logger.debug { "Flight For Player Was Blank #{p.id}" }
      end
    end

    if self.tournament.auto_schedule_for_multi_day == AutoScheduleType::AUTOMATIC_WORST_FIRST #worst golfer, worst flight
      Rails.logger.debug { "Scheduling #{players_with_scores.count} Golfers Worst to Best" }

      players_with_scores.sort! { |x,y| [y[:flight_number], y[:net_score]] <=> [x[:flight_number], x[:net_score]] }
    elsif self.tournament.auto_schedule_for_multi_day == AutoScheduleType::AUTOMATIC_BEST_FIRST #best golfer, best flight
      Rails.logger.debug { "Scheduling #{players_with_scores.count} Golfers Best to Worst" }

      players_with_scores.sort! { |x,y| [x[:flight_number], x[:net_score]] <=> [y[:flight_number], y[:net_score]] }
    else
      Rails.logger.debug { "Scheduling #{players_with_scores.count} Golfers Manual COPY" }

      players_with_scores.sort! { |x,y| [x[:flight_number], x[:previous_day_group_id]] <=> [y[:flight_number], y[:previous_day_group_id]] }
    end

    players_with_scores.each do |result|
      Rails.logger.debug { "Result: #{result[:player].complete_name} #{result[:net_score]} F: #{result[:flight_number]}" }
    end

    Rails.logger.debug { "Auto-Scheduling For Day: #{self.id}" }

    group_slots = []
    team_slots = []
    self.tournament_groups.each do |group|
      group.max_number_of_players.times do
        group_slots << group
      end

      if self.tournament.display_teams?
        group.golfer_teams.each do |t|
          t.max_players.times do
            team_slots << t
          end
        end
      end
    end

    players_with_scores.each_with_index do |player_score, index|
      player = player_score[:player]

      if group_slots.count > index
        slot = group_slots[index]

        existing_group = self.tournament_group_for_player(player)

        unless existing_group.blank?
          Rails.logger.debug { "Removing #{player.complete_name} from existing group #{existing_group.id}." }

          self.remove_player_from_group(existing_group, player, true)

          Rails.logger.debug { "Removed #{player.complete_name} from existing group #{existing_group.id}." }
        end

        Rails.logger.debug { "Adding Player #{player.complete_name} to group #{slot.id}." }

        self.add_player_to_group(slot, player, false, true)

        #add to new team
        if self.tournament.display_teams?
          team_slot = team_slots[index]

          Rails.logger.debug { "Adding Player #{player.complete_name} to team #{team_slot.id}." }

          team_slot.users << player
        end
      end
    end
  end

end
