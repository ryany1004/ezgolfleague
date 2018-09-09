class SendComplicationNotificationJob < ApplicationJob
  def perform(primary_scorecard)
    complication_cache_key = "#{primary_scorecard.id}-last_complication_push"
    last_complication_push = Rails.cache.fetch(complication_cache_key)
    if last_complication_push.blank? || last_complication_push < 5.minutes.ago
      primary_scorecard.tournament_day.tournament.players.each do |p|
        slim_leaderboard = FetchingTools::LeaderboardFetching.create_slimmed_down_leaderboard(primary_scorecard.tournament_day)
    
        p.send_complication_notification(slim_leaderboard)
      end

      Rails.cache.write(complication_cache_key, DateTime.now)
    end
  end
end
