module ContestScoreable
  extend ActiveSupport::Concern

  def contest_can_be_scored?
    if self.is_team_contest?
      if self.all_team_members_are_contestants? == true
        return true
      else
        return false
      end
    else
      return true
    end
  end

  def is_team_contest?
    if self.is_team_scored? and self.tournament_day.allow_teams != GameTypes::TEAMS_DISALLOWED
      return true
    else
      return false
    end
  end

  def all_team_members_are_contestants?
    self.tournament_day.golfer_teams.each do |team|
      team_participation = []

      if team.users.count > 0 #empty teams do not count
        team.users.each do |teammate|
          if self.users.include? teammate
            team_participation << true
          else
            team_participation << false
          end
        end
      end

      if team_participation.length > 0 and team_participation.uniq.length != 1 #all yes or all no is fine ; mix is not fine
        return false
      end
    end

    return true
  end

  def score_contest
    if self.contest_type == 2
      self.score_skins_contest(false)
    elsif self.contest_type == 3
      self.score_skins_contest(true)
    elsif self.contest_type == 4
      self.score_net_contest(false)
    elsif self.contest_type == 5
      self.score_net_contest(true)
    elsif self.contest_type == 6
      self.score_net_contest(false, true)
    elsif self.contest_type == 7
      self.score_net_contest(true, true)
    elsif self.contest_type == 8
      self.score_total_skins_contest
    end
  end

  def score_total_skins_contest
    Rails.logger.info { "CONTEST: #{self.id} Scoring Total Skins Contest" }

    self.remove_results
    self.save

    Rails.logger.info { "CONTEST: #{self.id} Scoring Gross Skins Winners" }
    gross_winners = self.users_with_skins(true, true)

    Rails.logger.info { "CONTEST: #{self.id} Scoring Net Skins Winners" }
    net_winners = self.users_with_skins(false, false)

    all_winners = []

    gross_winners.each do |w|
      all_winners << w
    end

    Rails.logger.info { "CONTEST: #{self.id} Merge Winner Sets" }
    net_winners.each do |w|
      all_winners.each do |all_winner|
        w[:winners].each do |w2|
          all_winner[:winners] << w2 if w[:hole] == all_winner[:hole]
        end
      end
    end

    Rails.logger.info { "CONTEST: #{self.id} Determining Value Per Skin and Assigning Payouts" }
    self.calculate_skins_winners(all_winners)

    Rails.logger.info { "CONTEST: #{self.id} score_total_skins_contest: complete" }
  end

  def score_skins_contest(use_gross)
    Rails.logger.info { "CONTEST: #{self.id} Scoring Skins Contest. Gross: #{use_gross}" }

    self.remove_results
    self.save

    all_winners = self.users_with_skins(use_gross)

    Rails.logger.info { "CONTEST: #{self.id} Determining Value Per Skin and Assigning Payouts" }
    self.calculate_skins_winners(all_winners)

    Rails.logger.info { "CONTEST: #{self.id} score_skins_contest: complete" }
  end

  def calculate_skins_winners(all_winners)
    winners_sum = 0
    all_winners.each do |w|
      winners = w[:winners]

      winners_sum += winners.count
    end

    if winners_sum == 0
      Rails.logger.info { "CONTEST: #{self.id} No Winners for Contest #{self.id}. Bailing on scoring..." }

      return
    end

    total_pot = (self.users.count * self.dues_amount)

    if total_pot > 0
      value_per_skin = (total_pot / winners_sum).floor
    else
      value_per_skin = 0
    end

    Rails.logger.info { "CONTEST: #{self.id} Value Per Skin: #{value_per_skin}. Total pot: #{total_pot}. Number of skins won: #{winners_sum}. Number of total users: #{self.users.count}" }

    all_winners.each do |winner_info|
      hole = winner_info[:hole]
      contest_hole = self.contest_holes.where(course_hole: hole).first
      hole_winners = winner_info[:winners]

      hole_winners.each do |winner|
        ContestResult.create(contest: self, winner: winner, payout_amount: value_per_skin, contest_hole: contest_hole, result_value: "Hole #{hole.hole_number}")
      end
    end

    #self.recalculate_contest_results_for_team_split if self.is_team_contest?
  end

  #TODO: turn contest results into payments

  # def recalculate_contest_results_for_team_split
  #   Rails.logger.info { "CONTEST: #{self.id} recalculate_contest_results_for_team_split" }
  #
  #   self.tournament_day.golfer_teams.each do |team|
  #     team_contest_results = ContestResult.where(contest: self).where(winner: team.users)
  #
  #     if team_contest_results.count > 1
  #       team_contest_results.in_groups(team.users.count, false).each_with_index do |result_group, i|
  #         user = team.users[i]
  #
  #         result_group.each do |result|
  #           result.winner = user
  #           result.save
  #         end
  #       end
  #     end
  #   end
  # end

  def users_with_skins(use_gross, gross_skins_require_birdies = false)
    all_winners = []

    self.course_holes.each do |hole|
      users_getting_skins = []
      gross_birdie_skins = []
      user_scores = []

      self.users.each do |user|
        if self.tournament_day.tournament.includes_player?(user) && !self.tournament_day.golf_outing_for_player(user).disqualified
          if use_gross == true
            use_handicap = false
          else
            use_handicap = true
          end

          score = self.tournament_day.compute_stroke_play_player_score(user, use_handicap, holes = [hole.hole_number]) #force stroke play calculation for other game types

          unless score.blank? || score == 0
            if gross_skins_require_birdies == true #check if gross birdie
              gross_birdie_score = (hole.par - 1)

              if score <= gross_birdie_score #gross birdies or better count
                if self.is_team_contest? #teams can only have ONE GROSS BIRDIE SKIN PER HOLE
                  teammates_have_birdie_skin_for_hole = false

                  team = self.tournament_day.golfer_team_for_player(user)
                  unless team.blank?
                    team.users.each do |teammate|
                      teammates_have_birdie_skin_for_hole = true if gross_birdie_skins.include? teammate
                    end
                  end

                  if teammates_have_birdie_skin_for_hole == false
                    Rails.logger.info { "CONTEST: #{self.id} Team #{team.id} for User #{user.id} DOES NOT Have Pre-Existing Birdies - Ok to Add" }

                    gross_birdie_skins << user

                    Rails.logger.info { "CONTEST: #{self.id} User #{user.complete_name} scored a gross birdie skin for hole #{hole.hole_number} w/ score #{score}. Required score: #{gross_birdie_score}" }
                  end
                else
                  gross_birdie_skins << user

                  Rails.logger.info { "CONTEST: #{self.id} User #{user.complete_name} scored a gross birdie skin for hole #{hole.hole_number} w/ score #{score}. Required score: #{gross_birdie_score}" }
                end
              end
            else #regular counting
              user_scores << {user: user, score: score}
            end
          else
            Rails.logger.info { "CONTEST: #{self.id} Score Blank - Not Scoring Contest. This is weird. #{user.complete_name}" }
          end
        else
          Rails.logger.info { "CONTEST: #{self.id} Tournament Day Does Not Include Contest Player - This is Weird. #{user.complete_name}" }
        end
      end

      if gross_skins_require_birdies == true
        gross_birdie_skins.each do |user|
          users_getting_skins << user
        end
      else
        user_scores.sort! { |x,y| x[:score] <=> y[:score] }

        unless user_scores.blank?
          if user_scores.count == 1
            users_getting_skins << user_scores[0][:user]

            Rails.logger.info { "CONTEST: #{self.id} User #{user_scores[0][:user].complete_name} got a regular skin for hole #{hole.hole_number}" }
          elsif user_scores.count > 1
            if user_scores[0][:score] != user_scores[1][:score] #if there is a tie, they do not count
              users_getting_skins << user_scores[0][:user]

              Rails.logger.info { "CONTEST: #{self.id} User #{user_scores[0][:user].complete_name} got a regular skin for hole #{hole.hole_number}" }
            else
              Rails.logger.info { "CONTEST: #{self.id} There was a tie - no skin awarded. #{user_scores[0][:user].complete_name} and #{user_scores[1][:user].complete_name} for hole #{hole.hole_number}" }
            end
          end
        end
      end

      all_winners << {hole: hole, winners: users_getting_skins}
    end

    return all_winners
  end

  def score_net_contest(use_gross, across_all_days = false)
    Rails.logger.info { "CONTEST: #{self.id} Scoring Net Contest. Gross: #{use_gross}" }

    self.overall_winner = nil
    self.save

    eligible_player_ids = self.tournament_day.game_type.eligible_players_for_payouts

    results = []
    if across_all_days == true
      tournament_day_results = TournamentDayResult.where(:id => self.tournament_day.tournament.tournament_days.map(&:id))
      tournament_day_results.each do |result|
        if eligible_player_ids.include? result.user.id and self.users.include? result.user
          Rails.logger.info { "CONTEST: #{self.id} Player Eligible for Contest: #{result.user.id}" }

          existing_user = nil

          results.each do |r|
            existing_user = r if r[:user] == result.user
          end

          if existing_user.blank?
            if use_gross == true
              results << {user: result.user, score: result.gross_score} unless result.gross_score.blank?
            else
              results << {user: result.user, score: result.net_score} unless result.net_score.blank?
            end
          else
            if use_gross == true
              existing_user[:score] += result.gross_score
            else
              existing_user[:score] += result.net_score
            end
          end
        else
          Rails.logger.info { "CONTEST: #{self.id} Player Not Eligible for Contest: #{result.user}" }
        end
      end
    else
      self.tournament_day.tournament_day_results.each do |result|
        if use_gross == true
          results << {user: result.user, score: result.gross_score} unless result.gross_score.blank?
        else
          results << {user: result.user, score: result.net_score} unless result.net_score.blank?
        end
      end
    end

    Rails.logger.info { "CONTEST: #{self.id} Results: #{results}" }

    #sort
    results.sort! { |x,y| x[:score] <=> y[:score] }

    #set winner
    unless results.blank? || results.count == 0
      if self.overall_winner_payout_amount.blank?
        total_value = (self.users.count * self.dues_amount).floor #automatic distribution
      else
        total_value = self.overall_winner_payout_amount
      end

      winner = results[0][:user]
      result_value = results[0][:score]

      self.overall_winner = ContestResult.create(winner: winner, payout_amount: total_value, result_value: "#{result_value}", points: self.overall_winner_points)
      self.save
    end
  end

end
