module TournamentDays
  module TournamentScorecardSupport
    def scorecard_cache_prefix(user:)
      "ScorecardIDToUserID#{self.id}-#{user.id}"
    end

    def primary_scorecard_for_user(user)
      cache_key = self.cache_key(scorecard_cache_prefix(user: user))
      scorecard_id = Rails.cache.fetch(cache_key)

      if scorecard_id.blank?
        eager_groups.each do |group|
          golf_outing = group.golf_outings.find_by(user: user)

          unless golf_outing.blank?
            scorecard = golf_outing.scorecard

            Rails.cache.write(cache_key, scorecard.id)

            return scorecard
          end
        end
      else
        return Scorecard.find_by(id: scorecard_id)
      end

      nil
    end

    def delete_cached_primary_scorecard(user:)
      cache_key = self.cache_key(self.scorecard_cache_prefix(user: user))

      Rails.cache.delete(cache_key)
    end

    def user_can_edit_scorecard(user, scorecard)
      return false if scorecard.blank?
      return false if self.tournament.is_past?
      return false if self.tournament.is_finalized == true
      return false if scorecard.is_potentially_editable? == false

      return true if scorecard.golf_outing.user == user
      return true if scorecard.designated_editor == user

      # check if they are on a team together
      team = scorecard.tournament_day.daily_team_for_player(user)
      unless team.blank?
        team.users.each do |u|
          return true if u == user and team.users.include? scorecard.golf_outing.user
        end
      end

      false
    end

    def user_can_become_designated_scorer(user, scorecard)
      return false if !scorecard.designated_editor.blank?

      group = scorecard.golf_outing.tournament_group
      self.scoring_rules.each do |rule|
        return true if rule.respond_to?(:other_group_members) && rule.other_group_members(user: user).include?(user)
      end

      false
    end
  end
end
