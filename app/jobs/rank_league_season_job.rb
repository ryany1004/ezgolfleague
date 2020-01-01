class RankLeagueSeasonJob < ApplicationJob
  queue_as :calculations

  def perform(league_season, destroy_first = false)
    return if league_season.blank?

    Rails.logger.info { "Ranking Season: #{league_season.id}" }

    LeagueSeason.transaction do
      Rankings::LeagueSeasonRankingGroupsRanking.compute_rank(league_season, destroy_first)
    end
  end
end
