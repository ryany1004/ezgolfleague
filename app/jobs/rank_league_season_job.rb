class RankLeagueSeasonJob < ApplicationJob
  def perform(league_season, destroy_first = false)
    return if league_season.blank?

    Rails.logger.info { "Ranking Season: #{league_season.id}" }

    LeagueSeason.transaction do
      LeagueSeasonRankingGroups::RankPosition.compute_rank(league_season, destroy_first)
    end
  end
end
