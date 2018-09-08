class RankLeagueSeasonJob < ApplicationJob
  def perform(league_season)
  	LeagueSeason.transaction do
  		Rails.logger.info { "RankLeagueSeasonJob #{league_season.id}" }

  		LeagueSeasonRankingGroups::RankPosition.compute_rank(league_season)
  	end
  end
end
