class RankLeagueSeasonJob < ApplicationJob
  def perform(league_season)
  	return if league_season.blank?

  	LeagueSeason.transaction do
  		Rails.logger.info { "RankLeagueSeasonJob #{league_season.id}" }

  		LeagueSeasonRankingGroups::RankPosition.compute_rank(league_season)
  	end
  end
end
