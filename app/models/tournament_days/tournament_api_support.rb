module TournamentApiSupport
  def registered_user_ids
    cache_key = "registereduserids-json#{self.id}-#{self.updated_at.to_i}"
    user_ids = []

    user_ids = Rails.cache.fetch(cache_key, expires_in: 5.minute, race_condition_ttl: 10) do
      self.tournament.players_for_day(self).each do |player|
        user_ids << player.id.to_s unless player.blank?
      end

      user_ids
    end

    user_ids
  end

  def paid_user_ids
    cache_key = "paiduserids-json#{self.id}-#{self.updated_at.to_i}"
    user_ids = []

    user_ids = Rails.cache.fetch(cache_key, expires_in: 5.minute, race_condition_ttl: 10) do
      self.tournament.players_for_day(self).each do |player|
        user_ids << player.id.to_s if self.tournament.user_has_paid?(player)
      end

      user_ids
    end

    user_ids
  end

  def superuser_user_ids
    user_ids = []

    self.tournament.players_for_day(self).each do |player|
      user_ids << player.id.to_s if player.is_super_user
    end

    user_ids
  end

  def league_admin_user_ids
    user_ids = []

    self.tournament.league.league_admins.each do |user|
      user_ids << user.id.to_s
    end

    user_ids
  end
end