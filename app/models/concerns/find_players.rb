module FindPlayers
  extend ActiveSupport::Concern

  def flight_for_player(user)
    self.flights.includes(:users).each do |f|
      return f if f.users.include? user
    end

    nil
  end

  def golfer_team_for_player(user)
    self.golfer_teams.includes(:users).each do |t|
      return t if t.users.include? user
    end

    nil
  end

  def tournament_group_for_player(user)
    self.tournament_groups.includes(golf_outings: [:user]).each do |group|
      group.golf_outings.each do |outing|
        return group if outing.user == user
      end
    end

    nil
  end

  def golf_outing_for_player(user)
    self.tournament_groups.includes(golf_outings: [:user]).each do |group|
      group.golf_outings.each do |outing|
        return outing if outing.user == user
      end
    end

    nil
  end

  def player_is_confirmed?(user)
    outing = self.golf_outing_for_player(user)

    if outing.blank?
      false
    else
      outing.is_confirmed
    end
  end

  def paid_contests_for_player(user)
    player_contests = []

    self.tournament.paid_contests.each do |c|
      player_contests << c if c.users.include?(user)
    end

    player_contests
  end

end
