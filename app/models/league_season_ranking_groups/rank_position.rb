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
      group.league_season_rankings.update_all(points: 0, payouts: 0)

      common_rank(group)
    end

    def rank_scoring_group_season
      league_season.league_season_ranking_groups.destroy_all # we always destroy these

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

          score_sum = 0
          number_of_days = 0

          t.tournament_days.includes(scoring_rules: [payout_results: :user]).find_each do |day|
            day.displayable_scoring_rules.includes(:payout_results).find_each do |rule|
              rule.payout_results.where(user: p).find_each do |result|
                Rails.logger.debug { "Adding #{result.points} points and #{result.amount} amount from rule #{rule.id} #{rule.name} on day #{day.id} to #{p.complete_name}" }

                ranking.points += result.points if result.points.present?
                ranking.payouts += result.amount if result.amount.present?
              end
            end

            next if day.scorecard_base_scoring_rule.blank?

            user_result = day.scorecard_base_scoring_rule.result_for_user(user: p)
            if user_result.present?
              score_sum += user_result.gross_score
              number_of_days += 1
            else
              Rails.logger.debug { "No Result for #{p.complete_name} for day #{day.id}" }
            end
          end

          if number_of_days.positive?
            ranking.average_score = score_sum / number_of_days

            Rails.logger.debug { "Setting Average Score #{ranking.average_score} to #{p.complete_name} with sum #{score_sum} and days #{number_of_days}" }
          end

          ranking.save
        end
      end
    end

    def create_team_season_rankings(group)
      league_season.league_season_teams.each do |team|
        ranking = group.league_season_rankings.find_or_create_by(league_season_team: team)

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

        ranking.average_score = 1 # we do not do averages for teams

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
      if league_season.rankings_by_scoring_average
        sorted_results = LeagueSeasonRanking.where(league_season_ranking_group: group).where('average_score > 0').sort { |x, y| x.user.handicap_index <=> y.user.handicap_index }
      else
        sorted_results = LeagueSeasonRanking.where(league_season_ranking_group: group).order(points: :desc)
      end

      # rank
      last_rank = 0
      last_points = 0
      quantity_at_rank = 0

      sorted_results.each_with_index do |result, i|
        if league_season.rankings_by_scoring_average
          slot_value = result.user.handicap_index
        else
          slot_value = result.points
        end

        # rank = last rank + 1
        # unless last_points are the same, then rank does not change
        # when last_points then does differ, need to move the rank up the number of slots
        if slot_value != last_points
          rank = last_rank + 1

          if quantity_at_rank.positive?
            quantity_at_rank = 0

            rank = i + 1
          end

          last_rank = rank
          last_points = slot_value
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
