class LeagueSeasonScoringGroup < ApplicationRecord
	belongs_to :league_season, inverse_of: :league_season_scoring_groups, touch: true
	has_many :flights, inverse_of: :league_season_scoring_group
	has_and_belongs_to_many :users, inverse_of: :league_season_scoring_groups

  def ranked_users
    ranked_players = []

    tournaments = Tournament.tournaments_happening_at_some_point(self.league_season.starts_at, self.league_season.ends_at, [self], true)
    tournaments.each do |t|
      self.users.each do |p|
        points = 0
        payouts = 0

        t.tournament_days.each do |day|
        	day_points = day.player_points(p)
        	day_payouts = day.player_payouts(p)

          points += day_points unless day_points.blank?
          payouts += day_payouts unless day_payouts.blank?
        end

        found_existing_player = false

        ranked_players.each do |r|
          if r[:id] == p.id
            r[:points] = r[:points] + points
            r[:payouts] = r[:payouts] + payouts

            found_existing_player = true
          end
        end

        if found_existing_player == false
          ranked_players << { id: p.id, name: p.complete_name, points: points, payouts: payouts, ranking: 0 }
        end
      end
    end

    ranked_players.sort! { |x,y| y[:points] <=> x[:points] }

    #now that players are sorted by points, rank them
    last_rank = 0
    last_points = 0
    quantity_at_rank = 0

    ranked_players.each_with_index do |player, i|
      #rank = last rank + 1
      #unless last_points are the same, then rank does not change
      #when last_points then does differ, need to move the rank up the number of slots

      if player[:points] != last_points
        rank = last_rank + 1

        if quantity_at_rank != 0
          quantity_at_rank = 0

          rank = i + 1
        end

        last_rank = rank
        last_points = player[:points]
      else
        rank = last_rank

        quantity_at_rank = quantity_at_rank + 1
      end

      player[:ranking] = rank
    end

    return ranked_players
  end
end
