module FindPlayers
  extend ActiveSupport::Concern

  def flight_for_player(user)
    self.flights.each do |f|
      return f if f.users.include? user
    end

    return nil
  end

  def golfer_team_for_player(user)
    self.golfer_teams.each do |t|
      return t if t.users.include? user
    end

    return nil
  end

  def tournament_group_for_player(user)
    Rails.logger.info { "tournament_group_for_player: #{user.id}" }

    self.tournament_groups.each do |group|
      group.golf_outings.each do |outing|
        return group if outing.user == user
      end
    end

    return nil
  end

  def golf_outing_for_player(user)
    self.tournament_groups.each do |group|
      group.golf_outings.each do |outing|
        return outing if outing.user == user
      end
    end

    return nil
  end

  def player_is_confirmed?(user)
    outing = self.golf_outing_for_player(user)

    if outing.blank?
      return false
    else
      return outing.is_confirmed
    end
  end

end
