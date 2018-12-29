module Playable
  extend ActiveSupport::Concern

  def display_teams?
    self.tournament_days.each do |day|
      return true if day.allow_teams == GameTypes::TEAMS_ALLOWED || day.allow_teams == GameTypes::TEAMS_REQUIRED
    end

    false
  end

  def players
    players = []

    self.tournament_days.each do |day|
      self.players_for_day(day).each do |player|
        players << player unless players.include? player
      end
    end

    players
  end

  def qualified_players
    players = []

    self.tournament_days.each do |day|
      self.players_for_day(day).each do |player|
        outing = day.golf_outing_for_player(player)

        players << player unless (outing.disqualified) || (players.include? player)
      end
    end

    players
  end

  def players_for_day(day)
    players = []

    day.tournament_groups.each do |group|
      group.players_signed_up.each do |player|
        players << player unless players.include? player
      end
    end

    players
  end

  def number_of_players
    return 0 if self.first_day.blank?

    number_of_players = 0

    self.first_day.tournament_groups.each do |group|
      number_of_players = number_of_players + group.players_signed_up.count
    end

    number_of_players
  end

  def includes_player?(user, restrict_to_day = nil)
    player_included = false

    if restrict_to_day.blank?
      days = self.tournament_days
    else
      days = [restrict_to_day]
    end

    days.each do |day|
      day.tournament_groups.each do |group|
        group.players_signed_up.each do |player|
          player_included = true if player == user
        end
      end
    end

    player_included
  end

  def confirm_player(user)
    self.tournament_days.each do |day|
      day.tournament_groups.each do |group|
        group.golf_outings.each do |outing|
          if outing.user == user
            outing.is_confirmed = true
            outing.save
          end
        end
      end
    end
  end

  def total_score(user)
    total_score = 0

    self.tournament_days.each do |day|
      day.scoring_rules.each do |rule|
        result = rule.result_for_user(user: user)
        total_score += result.net_score unless result.blank?
      end
    end

    total_score
  end

  def total_points(user)
    total_points = 0

    self.tournament_days.each do |day|
      day.scoring_rules.each do |rule|
        total_points += rule.points_for_user(user: user)
      end
    end

    total_points
  end

end
