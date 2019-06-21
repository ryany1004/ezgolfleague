module LeagueSeasonRankingGroups
  class RankPosition
    attr_accessor :league_season
    attr_accessor :sorted_results

    def self.compute_rank(league_season, destroy_first = false)
      rank_computer = self.new
      rank_computer.league_season = league_season

      league_season.league_season_ranking_groups.destroy_all if destroy_first

      if league_season.league.allow_scoring_groups
        rank_computer.rank_scoring_group_season
      else
        rank_computer.rank_regular_season
      end
    end

    def rank_regular_season
      group = LeagueSeasonRankingGroup.find_or_create_by(name: league_season.name, league_season: league_season)

      common_rank(group)
    end

    def rank_scoring_group_season
      league_season.league_season_scoring_groups.each do |scoring_group|
        group = LeagueSeasonRankingGroup.find_or_create_by(name: scoring_group.name, league_season: league_season)

        common_rank(group, scoring_group.users)
      end
    end

    def create_individual_season_rankings(group, limit_to_players = nil)
      league_season.tournaments.includes(:tournament_days).find_each do |t|
        players = t.players
        players = players.select { |item| limit_to_players.include? item } if limit_to_players.present?

        players.each do |p|
          ranking = group.league_season_rankings.find_or_create_by(user: p)
          ranking.points = 0
          ranking.payouts = 0

          t.tournament_days.includes(scoring_rules: [payout_results: :user]).find_each do |day|
            day.displayable_scoring_rules.includes(:payout_results).find_each do |rule|
              rule.payout_results.where(user: p).find_each do |result|
                Rails.logger.debug { "Adding #{result.points} points and #{result.amount} amount from rule #{rule.id} #{rule.name} on day #{day.id} to #{p.complete_name}" }

                ranking.points += result.points if result.points.present?
                ranking.payouts += result.amount if result.amount.present?
              end
            end
          end

          ranking.save
        end
      end
    end

    def create_team_season_rankings(group)
      league_season.league_season_teams.each do |team|
        ranking = group.league_season_rankings.find_or_create_by(league_season_team: team)
        ranking.points = 0
        ranking.payouts = 0

        league_season.tournaments.includes(:tournament_days).find_each do |t|
          t.tournament_days.includes(scoring_rules: [payout_results: :league_season_team]).find_each do |day|
            day.displayable_scoring_rules.includes(:payout_results).find_each do |rule|
              rule.payout_results.where(league_season_team: team).find_each do |result| # add the team results
                ranking.points += result.points if result.points.present?
                ranking.payouts += result.amount if result.amount.present?
              end

              # this is a team season so also add the individual results, if any
              team.users.each do |p|
                rule.payout_results.where(user: p).find_each do |result|
                  ranking.points += result.points if result.points.present?
                  ranking.payouts += result.amount if result.amount.present?
                end
              end
            end
          end
        end

        ranking.save
      end
    end

    def common_rank(group, limit_to_players = nil)
      if league_season.is_teams?
        create_team_season_rankings(group)
      else
        create_individual_season_rankings(group, limit_to_players)
      end

      # sort
      sorted_results = group.league_season_rankings.sort { |x, y| y.points <=> x.points }

      # rank
      last_rank = 0
      last_points = 0
      quantity_at_rank = 0

      sorted_results.each_with_index do |result, i|
        # rank = last rank + 1
        # unless last_points are the same, then rank does not change
        # when last_points then does differ, need to move the rank up the number of slots
        if result.points != last_points
          rank = last_rank + 1

          if quantity_at_rank != 0
            quantity_at_rank = 0

            rank = i + 1
          end

          last_rank = rank
          last_points = result.points
        else
          rank = last_rank

          quantity_at_rank += 1
        end

        result.reload
        result.lock!
        result.rank = rank
        result.save
      end
    end
  end
end
