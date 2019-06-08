module Autoschedule
  def schedule_golfers
    previous_day = self.tournament.previous_day_for_day(self)
    return if previous_day.blank?

    self.tournament.tournament_days.first.assign_users_to_flights(should_destroy_results: false)

    Rails.logger.info { "Completed Auto-Schedule Flighting" }

    players_with_scores = []
    self.tournament.players.each do |p|
      flight = previous_day.flight_for_player(p)
      group = previous_day.tournament_group_for_player(p)

      result = previous_day.scorecard_base_scoring_rule.result_for_user(user: p)
      if result.blank? # this is a hack for Best Ball # TODO FIX ME
        result_name = Users::ResultName.result_name_for_user(p, previous_day.scorecard_base_scoring_rule)
        result = previous_day.scorecard_base_scoring_rule.tournament_day_results.find_by(name: result_name)
      end

      next if result.blank?

      net_score = result.net_score

      unless flight.blank?
        players_with_scores << {player: p, flight_number: flight.flight_number, net_score: net_score, previous_day_group_id: group.id}
      else
        Rails.logger.info { "Flight For Player Was Blank #{p.id}" }
      end
    end

    if self.tournament.auto_schedule_for_multi_day == AutoScheduleType::AUTOMATIC_WORST_FIRST # worst golfer, worst flight
      Rails.logger.info { "Scheduling #{players_with_scores.count} Golfers Worst to Best" }

      players_with_scores.sort! { |x,y| [y[:flight_number], y[:net_score]] <=> [x[:flight_number], x[:net_score]] }
    elsif self.tournament.auto_schedule_for_multi_day == AutoScheduleType::AUTOMATIC_BEST_FIRST # best golfer, best flight
      Rails.logger.info { "Scheduling #{players_with_scores.count} Golfers Best to Worst" }

      players_with_scores.sort! { |x,y| [x[:flight_number], x[:net_score]] <=> [y[:flight_number], y[:net_score]] }
    else
      Rails.logger.info { "Scheduling #{players_with_scores.count} Golfers Manual COPY" }

      players_with_scores.sort! { |x,y| [x[:flight_number], x[:previous_day_group_id]] <=> [y[:flight_number], y[:previous_day_group_id]] }
    end

    players_with_scores.each do |result|
      Rails.logger.info { "Result: #{result[:player].complete_name} #{result[:net_score]} F: #{result[:flight_number]}" }
    end

    Rails.logger.info { "Auto-Scheduling For Day: #{self.id}" }

    group_slots = []
    team_slots = []
    self.tournament_groups.each do |group|
      group.max_number_of_players.times do
        group_slots << group
      end

      if self.tournament.display_teams?
        group.daily_teams.each do |t|
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
          Rails.logger.info { "Removing #{player.complete_name} from existing group #{existing_group.id}." }

          self.remove_player_from_group(tournament_group: existing_group, user: player, remove_from_teams: true)

          Rails.logger.info { "Removed #{player.complete_name} from existing group #{existing_group.id}." }
        end

        Rails.logger.info { "Adding Player #{player.complete_name} to group #{slot.id}." }

        self.add_player_to_group(tournament_group: slot, user: player, paying_with_credit_card: false, confirmed: true, registered_by: "Auto-Schedule")

        #add to new team
        if self.tournament.display_teams?
          team_slot = team_slots[index]

          Rails.logger.info { "Adding Player #{player.complete_name} to team #{team_slot.id}." }

          team_slot.users << player
        end
      end
    end
  end
end