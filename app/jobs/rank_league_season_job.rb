class RankLeagueSeasonJob < ApplicationJob
  def perform(league_season)
  	LeagueSeasonRankingGroups::RankPosition.compute_rank(league_season)
  end
end
