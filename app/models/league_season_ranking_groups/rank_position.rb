module LeagueSeasonRankingGroups
	class RankPosition
		attr_accessor :league_season
		attr_accessor :sorted_results

		def self.compute_rank(league_season)
			rank_computer = self.new
			rank_computer.league_season = league_season

			league_season.league_season_ranking_groups.destroy_all

			if league_season.league.allow_scoring_groups
				rank_computer.rank_scoring_group_season
			else
				rank_computer.rank_regular_season
			end
		end

		def rank_regular_season
			group = LeagueSeasonRankingGroup.create(name: self.league_season.name, league_season: self.league_season)

			self.common_rank(group)
		end

		def rank_scoring_group_season
			league_season.league_season_scoring_groups.each do |scoring_group|
				group = LeagueSeasonRankingGroup.create(name: scoring_group.name, league_season: self.league_season)

				self.common_rank(group, scoring_group.users)
			end
		end

		def common_rank(group = nil, limit_to_players = nil)
			self.league_season.tournaments.each do |t|
				players = t.players
				players = players.select { |item| limit_to_players.include? item } unless limit_to_players.blank?

	      players.each do |p|
	      	ranking = group.league_season_rankings.where(user: p).first
	      	ranking = LeagueSeasonRanking.create(user: p, league_season_ranking_group: group) if ranking.blank?

	        t.tournament_days.includes(:tournament_day_results).each do |day|
	          day.tournament_day_results.where(user: p).limit(1).each do |result|
	            ranking.points += result.points
	            ranking.payouts += result.payouts
	          end
	        end

	        ranking.save
	      end
			end

			#sort
			self.sorted_results = group.league_season_rankings.sort { |x,y| y.points <=> x.points }

			#rank
	    last_rank = 0
	    last_points = 0
	    quantity_at_rank = 0

	    self.sorted_results.each_with_index do |result, i|
	      #rank = last rank + 1
	      #unless last_points are the same, then rank does not change
	      #when last_points then does differ, need to move the rank up the number of slots

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

	        quantity_at_rank = quantity_at_rank + 1
	      end

	      result.rank = rank
	      result.save
	    end
		end

	end
end