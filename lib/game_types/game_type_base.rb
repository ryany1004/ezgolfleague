module GameTypes
  TEAMS_ALLOWED = "Allowed"
  TEAMS_REQUIRED = "Required"
  TEAMS_DISALLOWED = "Disallowed"

  VARIABLE = -1

  class GameTypeBase
    include Rails.application.routes.url_helpers

    attr_accessor :tournament_day

    def self.available_types
      #return [GameTypes::IndividualStrokePlay.new, GameTypes::IndividualMatchPlay.new, GameTypes::IndividualModifiedStableford.new, GameTypes::TwoManShamble.new, GameTypes::TwoManScramble.new, GameTypes::FourManScramble.new, GameTypes::TwoManBestBall.new, GameTypes::TwoBestBallsOfFour.new, GameTypes::TwoManComboScrambleBestBall.new, GameTypes::OneTwoThreeBestBallsOfFour.new]
      return [GameTypes::IndividualStrokePlay.new, GameTypes::TwoManIndividualStrokePlay.new, GameTypes::IndividualModifiedStableford.new, GameTypes::TwoManScramble.new, GameTypes::FourManScramble.new, GameTypes::TwoManBestBall.new]
    end

    def display_name
      return nil
    end

    def game_type_id
      return nil
    end

    def tournament
      return self.tournament_day.tournament
    end

    ##Setup

    def can_be_played?
      return false
    end

    def can_be_finalized?
      flight_payouts = 0
      self.tournament_day.flights.each do |f|
        flight_payouts += f.payouts.count
      end

      broken_contests = 0
      self.tournament_day.tournament.tournament_days.includes(:contests).each do |day|
        day.contests.each do |c|
          broken_contests += 1 if c.contest_can_be_scored? == false
        end
      end

      players = 0
      players = self.tournament_day.tournament.players.count

      has_scores = false
      has_scores = self.tournament_day.has_scores?

      if flight_payouts == 0 or broken_contests > 0 or players == 0 or has_scores == false
        return false
      else
        return true
      end
    end

    def show_other_scorecards?
      false
    end

    def setup_partial
      return nil
    end

    def save_setup_details(game_type_options)
      #do nothing
    end

    def remove_game_type_options
      #do nothing
    end

    def leaderboard_partial_name
      'standard_leaderboard'
    end

    ##Group

    def other_group_members(user)
      return nil
    end

    def user_is_in_group?(user, tournament_group)
      return false
    end

    ##Teams

    def allow_teams
      return GameTypes::TEAMS_DISALLOWED
    end

    def show_teams?
      return false
    end

    def number_of_players_per_team
      return 0
    end

    def players_create_teams?
      return true
    end

    def show_team_scores_for_all_teammates?
      return true
    end

    def team_players_are_opponents?
      return false
    end

    ##Scoring

    def after_updating_scores_for_scorecard(scorecard)
      #nada
    end

    def related_scorecards_for_user(user, only_human_scorecards = false)
      return []
    end

    def player_score(user, use_handicap = true, holes = [])
      # tournament_day_result = self.tournament_day.tournament_day_results.where(aggregated_result: false).where(user: user).first

      # if tournament_day_result.blank?
      #   tournament_day_result = self.tournament_day.score_user(user) 

      #   RankFlightsJob.perform_later(self.tournament_day)
      # end

      # return 0 if tournament_day_result.blank?

      # if holes == [10, 11, 12, 13, 14, 15, 16, 17, 18]
      #   if use_handicap == true
      #     score = tournament_day_result.back_nine_net_score
      #   else
      #     score = self.compute_player_score(user, false, holes)
      #   end
      # elsif holes == [1, 2, 3, 4, 5, 6, 7, 8, 9]
      #   if use_handicap == true
      #     score = tournament_day_result.front_nine_net_score
      #   else
      #     score = tournament_day_result.front_nine_gross_score
      #   end
      # else
      #   if use_handicap == true
      #     score = tournament_day_result.net_score
      #   else
      #     score = tournament_day_result.gross_score
      #   end
      # end

      # score

      0
    end

    def compute_stroke_play_player_score(user, use_handicap = true, holes = [])
      # return nil if !self.tournament.includes_player?(user)

      # if use_handicap == true
      #   handicap_allowance = self.tournament_day.handicap_allowance(user)

      #   Rails.logger.debug { "Handicap Allowance: #{handicap_allowance}" }
      # end

      # scorecard = self.tournament_day.primary_scorecard_for_user(user)
      # if scorecard.blank?
      #   Rails.logger.debug { "Returning 0 - No Scorecard" }

      #   return 0
      # end

      # total_score = 0

      # total_score = Rails.cache.fetch("scorecard#{scorecard.id}-#{use_handicap}-#{holes.map {|s|"#{s}" }.join('-')}-#{scorecard.updated_at.to_i}", expires_in: 20.minute, race_condition_ttl: 10) do
      #   Rails.logger.debug { "Scorecard has #{scorecard.scores.count} scores." }

      #   scorecard.scores.includes(:course_hole).each do |score|
      #     should_include_score = true #allows us to calculate partial scores, i.e. back 9
      #     if holes.blank? == false
      #       should_include_score = false if !holes.include? score.course_hole.hole_number
      #     end

      #     if should_include_score == true
      #       hole_score = score.strokes

      #       Rails.logger.debug { "Hole: #{score.course_hole.hole_number} - Score Strokes #{score.strokes}" }

      #       #TODO: re-factor with below method
      #       if use_handicap == true && !handicap_allowance.blank?
      #         handicap_allowance.each do |h|
      #           if h[:course_hole] == score.course_hole
      #             if h[:strokes] != 0
      #               Rails.logger.debug { "Handicap Adjusting Hole #{score.course_hole.hole_number} Score From #{hole_score} w/ Handicap Strokes #{h[:strokes]}" }

      #               adjusted_hole_score = hole_score - h[:strokes]
      #               hole_score = adjusted_hole_score if adjusted_hole_score > 0

      #               Rails.logger.debug { "Handicap Adjusted: #{hole_score}" }
      #             end
      #           end
      #         end
      #       end

      #       total_score = total_score + hole_score
      #     end
      #   end

      #   total_score = 0 if total_score < 0

      #   Rails.logger.debug { "Base Score Computed: #{total_score}. User: #{user.complete_name} use handicap: #{use_handicap} holes: #{holes}" }

      #   total_score
      # end

      # total_score

      0
    end

    def compute_player_score(user, use_handicap = true, holes = [])
      #return self.compute_stroke_play_player_score(user, use_handicap, holes)
      nil
    end

    def compute_adjusted_player_score(user)
      # Rails.logger.info { "compute_adjusted_player_score: #{user.complete_name}" }

      # return nil if !self.tournament.includes_player?(user)

      # scorecard = self.tournament_day.primary_scorecard_for_user(user)
      # if scorecard.blank?
      #   Rails.logger.info { "Returning 0 - No Scorecard" }

      #   return 0
      # end

      # total_score = 0

      # scorecard.scores.each do |score|
      #   adjusted_score = self.score_or_maximum_for_hole(score.strokes, scorecard.golf_outing.course_handicap, score.course_hole)

      #   total_score = total_score + adjusted_score
      # end

      # Rails.logger.info { "User Adjusted Score: #{user.complete_name} - #{total_score}" }

      # total_score = 0 if total_score < 0

      # return total_score

      0
    end

    # def score_or_maximum_for_hole(strokes, course_handicap, hole)
    #   if course_handicap == 0
    #     Rails.logger.debug { "No Course Handicap" }

    #     return strokes
    #   end

    #   double_bogey = hole.par + 2

    #   Rails.logger.info { "Double Bogey for #{hole.hole_number} - #{double_bogey}" }

    #   if strokes <= double_bogey
    #     Rails.logger.info { "Strokes <= double_bogey: #{double_bogey}. #{strokes}" }

    #     return strokes
    #   else
    #     adjusted_score = strokes

    #     case course_handicap
    #     when 0..9
    #       adjusted_score = double_bogey
    #     when 10..19
    #       adjusted_score = 7
    #     when 20..29
    #       adjusted_score = 8
    #     when 30..39
    #       adjusted_score = 9
    #     else
    #       adjusted_score = 10
    #     end

    #     if adjusted_score <= strokes
    #       Rails.logger.info { "Adjusted Score for #{hole.hole_number} (Par #{hole.par}) w/ strokes: #{strokes} = #{adjusted_score}. Course handicap: #{course_handicap}" }

    #       return adjusted_score
    #     else
    #       Rails.logger.info { "Adjusted Score Was Too High... Bailing" }

    #       return strokes
    #     end
    #   end
    # end

    def player_points(user)
      # return nil if !self.tournament.includes_player?(user)

      # points = 0

      # self.tournament_day.payout_results.each do |p|
      #   points = points + p.points if p.user == user && p.points
      # end

      # #contests
      # self.tournament_day.contests.each do |c|
      #   c.combined_contest_results.each do |r|
      #     points = points + r.points if r.winner == user
      #   end
      # end

      # return points
    end

    def player_payouts(user)
      # return nil if !self.tournament.includes_player?(user)

      # payouts = 0

      # self.tournament_day.payout_results.each do |p|
      #   payouts = payouts + p.amount if p.user == user && p.amount
      # end

      # #contests
      # self.tournament_day.contests.each do |c|
      #   c.combined_contest_results.each do |r|
      #     payouts = payouts + r.payout_amount if r.winner == user && r.payout_amount
      #   end
      # end

      # return payouts
    end

    def includes_extra_scoring_column?
      return false
    end

    def override_scorecard_name_for_scorecard(scorecard)
      return nil
    end

    ##Metadata

    def update_metadata(metadata)
      #do nothing
    end

    ##UI

    def scorecard_score_cell_partial
      return nil
    end

    def scorecard_post_embed_partial
      return nil
    end

    def associated_text_for_score(score)
      return nil
    end

    ##API

    def scorecard_payload_for_scorecard(scorecard)
      scorecard_api = ScorecardAPIBase.new
      scorecard_api.tournament_day = self.tournament_day
      scorecard_api.scorecard = scorecard
      scorecard_api.handicap_allowance = self.handicap_allowance(scorecard.golf_outing.user)

      return scorecard_api.scorecard_representation
    end

    ##Handicap

    def course_handicap_for_game_type(golf_outing)
      return golf_outing.course_handicap
    end

    def handicap_allowance(user)
      golf_outing = self.tournament_day.golf_outing_for_player(user)
      return nil if golf_outing.blank? #did not play

      course_handicap = self.course_handicap_for_game_type(golf_outing)

      ##
      allowance = Rails.cache.fetch("golf_outing#{golf_outing.id}-#{golf_outing.updated_at.to_i}", expires_in: 15.minute, race_condition_ttl: 10) do
        return nil if golf_outing.course_tee_box.blank?

        Rails.logger.debug { "Course Handicap: #{course_handicap}" }

        if golf_outing.course_tee_box.tee_box_gender == "Men"
          sorted_course_holes_by_handicap = self.tournament_day.course_holes.reorder("mens_handicap")
        else
          sorted_course_holes_by_handicap = self.tournament_day.course_holes.reorder("womens_handicap")
        end

        if !course_handicap.blank?
          allowance = []
          while course_handicap > 0 do
            sorted_course_holes_by_handicap.each do |hole|
              existing_hole = nil

              allowance.each do |a|
                if hole == a[:course_hole]
                  existing_hole = a
                end
              end

              if existing_hole.blank?
                existing_hole = {course_hole: hole, strokes: 0}
                allowance << existing_hole
              end

              if course_handicap > 0
                existing_hole[:strokes] = existing_hole[:strokes] + 1
                course_handicap = course_handicap - 1
              end
            end
          end

          allowance
        else
          nil
        end
      end

      allowance
    end

    ##Ranking

    def players_for_flight(flight)
      if self.tournament_day.golfer_teams.count == 0
        return flight.users
      else
        players = []
        players_to_omit = []

        flight.users.each do |u|
          players << u if (!players.include? u) && (!players_to_omit.include? u)
        end

        return players
      end
    end

    def flights_with_rankings
      eager_flights = self.tournament_day.flights.includes(:users, :tournament_day_results, :payout_results)
    end

    ##Payouts

    def eligible_players_for_payouts
      Rails.logger.debug { "eligible_players_for_payouts" }

      eligible_player_list = []
      if self.tournament.tournament_days.count == 1
        eligible_player_list = self.tournament.qualified_players.map(&:id)
      else #only players that play all days can win
        self.tournament.qualified_players.each do |player|
          player_played_all_days = true

          self.tournament.tournament_days.each do |day|
            player_played_all_days = false if self.tournament.includes_player?(player, day) == false
          end

          eligible_player_list << player.id if player_played_all_days == true
        end
      end

      Rails.logger.debug { "Completed eligible_players_for_payouts" }

      return eligible_player_list
    end

    def assign_payouts_from_scores
      self.tournament_day.payout_results.destroy_all

      payout_count = 0
      self.tournament_day.flights.each do |flight|
        payout_count += flight.payouts.count
      end

      Rails.logger.info { "Payouts: #{payout_count}" }

      return if payout_count == 0

      if self.tournament.tournament_days.count > 1 && self.tournament_day == self.tournament.last_day
        eligible_player_list = self.eligible_players_for_payouts

        rankings = []
        self.tournament.tournament_days.each do |day|
          rankings << day.flights_with_rankings
        end

        ranked_flights = self.tournament.combine_rankings(rankings)
      else
        eligible_player_list = self.tournament.players.map(&:id)

        ranked_flights = self.flights_with_rankings
      end

      ranked_flights.each do |flight|
        flight.payouts.each_with_index do |payout, i|
          if payout.payout_results.count == 0
            result = flight.tournament_day_results[i]
            if result.present? and eligible_player_list.include? result.user.id
              player = result.user

              Rails.logger.info { "Assigning #{player.complete_name} to Payout #{payout.id}. Result ID: #{result.id}" }

              PayoutResult.create(payout: payout, user: player, flight: flight, tournament_day: flight.tournament_day, amount: payout.amount, points: payout.points)
            end
          else
            Rails.logger.info { "Payout Already Has Results: #{payout.payout_results.map(&:id)}" }
          end
        end
      end
    end

  end
end
