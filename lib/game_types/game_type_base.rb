module GameTypes
  TEAMS_ALLOWED = "Allowed"
  TEAMS_REQUIRED = "Required"
  TEAMS_DISALLOWED = "Disallowed"

  VARIABLE = -1

  class GameTypeBase
    include Rails.application.routes.url_helpers

    attr_accessor :tournament_day

    def self.available_types
      return [GameTypes::IndividualStrokePlay.new, GameTypes::IndividualMatchPlay.new, GameTypes::IndividualModifiedStableford.new, GameTypes::TwoManShamble.new, GameTypes::TwoManScramble.new, GameTypes::FourManScramble.new, GameTypes::TwoManBestBall.new, GameTypes::TwoBestBallsOfFour.new, GameTypes::TwoManComboScrambleBestBall.new, GameTypes::OneTwoThreeBestBallsOfFour.new]
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
      self.tournament_day.tournament.tournament_days.each do |day|
        day.contests.each do |c|
          broken_contests += 1 if c.contest_can_be_scored? == false
        end
      end

      if flight_payouts == 0 or broken_contests > 0
        return false
      else
        return true
      end
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
      tournament_day_result = self.tournament_day.tournament_day_results.where(user: user).first
      tournament_day_result = self.tournament_day.score_user(user) if tournament_day_result.blank?

      if holes == [10, 11, 12, 13, 14, 15, 16, 17, 18]
        if use_handicap == true
          return tournament_day_result.back_nine_net_score
        else
          return self.compute_player_score(user, false, holes)
        end
      elsif holes == [1, 2, 3, 4, 5, 6, 7, 8, 9]
        if use_handicap == true
          return tournament_day_result.front_nine_net_score
        else
          return tournament_day_result.front_nine_gross_score
        end
      else
        if use_handicap == true
          return tournament_day_result.net_score
        else
          return tournament_day_result.gross_score
        end
      end
    end

    def compute_stroke_play_player_score(user, use_handicap = true, holes = [])
      return nil if !self.tournament.includes_player?(user)

      total_score = 0

      handicap_allowance = self.tournament_day.handicap_allowance(user)

      scorecard = self.tournament_day.primary_scorecard_for_user(user)
      if scorecard.blank?
        Rails.logger.debug { "Returning 0 - No Scorecard" }

        return 0
      end

      scorecard.scores.each do |score|
        should_include_score = true #allows us to calculate partial scores, i.e. back 9
        if holes.blank? == false
          should_include_score = false if !holes.include? score.course_hole.hole_number
        end

        if should_include_score == true
          hole_score = score.strokes

          Rails.logger.debug { "Hole: #{score.course_hole.hole_number} - Strokes #{score.strokes}" }

          if use_handicap == true && !handicap_allowance.blank?
            handicap_allowance.each do |h|
              if h[:course_hole] == score.course_hole
                if h[:strokes] != 0
                  Rails.logger.debug { "Adjusting Hole Score From #{hole_score} w/ #{h[:strokes]}" }

                  adjusted_hole_score = hole_score - h[:strokes]
                  hole_score = adjusted_hole_score if adjusted_hole_score > 0

                  Rails.logger.debug { "Adjusted: #{hole_score}" }
                end
              end
            end
          end

          total_score = total_score + hole_score
        end
      end

      total_score = 0 if total_score < 0

      Rails.logger.debug { "Base Score Computed: #{total_score}. User: #{user.complete_name} handicap: #{use_handicap} holes: #{holes}" }

      return total_score
    end

    def compute_player_score(user, use_handicap = true, holes = [])
      return self.compute_stroke_play_player_score(user, use_handicap, holes)
    end

    def compute_adjusted_player_score(user)
      Rails.logger.info { "compute_adjusted_player_score: #{user.complete_name}" }

      return nil if !self.tournament.includes_player?(user)

      scorecard = self.tournament_day.primary_scorecard_for_user(user)
      if scorecard.blank?
        Rails.logger.info { "Returning 0 - No Scorecard" }

        return 0
      end

      total_score = 0

      scorecard.scores.each do |score|
        adjusted_score = self.score_or_maximum_for_hole(score.strokes, scorecard.golf_outing.course_handicap, score.course_hole)

        total_score = total_score + adjusted_score
      end

      Rails.logger.info { "User Adjusted Score: #{user.complete_name} - #{total_score}" }

      total_score = 0 if total_score < 0

      return total_score
    end

    def score_or_maximum_for_hole(strokes, course_handicap, hole)
      if course_handicap == 0
        Rails.logger.debug { "No Course Handicap" }

        return strokes
      end

      double_bogey = hole.par + 2

      Rails.logger.info { "Double Bogey for #{hole.hole_number} - #{double_bogey}" }

      if strokes <= double_bogey
        Rails.logger.info { "Strokes <= double_bogey: #{double_bogey}. #{strokes}" }

        return strokes
      else
        adjusted_score = strokes

        case course_handicap
        when 0..9
          adjusted_score = double_bogey
        when 10..19
          adjusted_score = 7
        when 20..29
          adjusted_score = 8
        when 30..39
          adjusted_score = 9
        else
          adjusted_score = 10
        end

        if adjusted_score <= strokes
          Rails.logger.info { "Adjusted Score for #{hole.hole_number} (Par #{hole.par}) w/ strokes: #{strokes} = #{adjusted_score}. Course handicap: #{course_handicap}" }

          return adjusted_score
        else
          Rails.logger.info { "Adjusted Score Was Too High... Bailing" }

          return strokes
        end
      end
    end

    def player_points(user)
      return nil if !self.tournament.includes_player?(user)

      points = 0

      self.tournament_day.payout_results.each do |p|
        points = points + p.points if p.user == user
      end

      #contests
      self.tournament_day.contests.each do |c|
        c.contest_results.each do |r|
          points = points + r.points if r.winner == user
        end
      end

      return points
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

    def handicap_allowance(user)
      golf_outing = self.tournament_day.golf_outing_for_player(user)
      return nil if golf_outing.blank? #did not play

      course_handicap = golf_outing.course_handicap

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

        return allowance
      else
        return nil
      end
    end

    ##Ranking

    def players_for_flight(flight)
      if self.tournament_day.golfer_teams.count == 0
        return flight.users
      else
        players = []
        players_to_omit = []

        flight.users.each do |u| #NOTE: should we sort the users so that they come back in a consistent order #could matter re: scorecards and teams
          players << u if (!players.include? u) && (!players_to_omit.include? u)

          team = self.tournament_day.golfer_team_for_player(u)
          unless team.blank?
            team.users.each do |team_user|
              players_to_omit << team_user
            end
          end
        end

        return players
      end
    end

    def player_team_name_for_player(player)
      if self.tournament_day.golfer_teams.count == 0
        return player.complete_name
      else
        team_name = ""

        team = self.tournament_day.golfer_team_for_player(player)
        team.users.each do |team_user|
          team_name = team_name + "#{team_user.last_name}"

          team_name = team_name + " / " unless team_user == team.users.last
        end

        return team_name
      end
    end

    def player_par_relation_for_tournament_day(player, tournament_day, use_handicap = true)
      result = tournament_day.tournament_day_results.where(user: player).first
      return nil if result.blank?

      if use_handicap == true
        return result.par_related_net_score
      else
        return result.par_related_gross_score
      end
    end

    def flights_with_rankings
      ranked_flights = []

      eager_flights = self.tournament_day.flights.includes(:users, :tournament_day_results)

      eager_flights.each do |f|
        ranked_flight = { flight_id: f.id, flight_number: f.flight_number, players: [] }

        rankable_players = self.players_for_flight(f)
        rankable_players.each do |player|
          Rails.logger.debug { "Fetching Net Score" }
          net_score = self.player_score(player, true)

          Rails.logger.debug { "Fetching Back Nine Net Score" }
          back_nine_net_score = self.player_score(player, true, [10, 11, 12, 13, 14, 15, 16, 17, 18])

          Rails.logger.debug { "Fetching Gross Score" }
          gross_score = self.player_score(player, false)

          par_related_net_score = self.player_par_relation_for_tournament_day(player, self.tournament_day, true)
          par_related_gross_score = self.player_par_relation_for_tournament_day(player, self.tournament_day, false)

          Rails.logger.info { "Ranking Player: #{player.complete_name} in Flight #{f.flight_number}. Net: #{net_score} Gross: #{gross_score}" }

          scorecard = self.tournament_day.primary_scorecard_for_user(player)
          unless scorecard.blank?
            scorecard_url = play_scorecard_path(scorecard)
          else
            Rails.logger.info { "Error Finding Scorecard For #{player.id}" }

            scorecard_url = "#"
          end

          points = 0
          f.payout_results.each do |payout_result|
            points = payout_result.points if payout_result.user == player
          end

          if !net_score.blank? && net_score > 0
            ranked_flight[:players] << { id: player.id, name: self.player_team_name_for_player(player), net_score: net_score, back_nine_net_score: back_nine_net_score, gross_score: gross_score, scorecard_url: scorecard_url, points: points, par_related_net_score: par_related_net_score, par_related_gross_score: par_related_gross_score, thru: scorecard.last_hole_played }
          else
            Rails.logger.info { "Not Including Player in Ranking. Net Score: #{net_score}" }
          end
        end

        self.sort_rank_players_in_flight!(ranked_flight[:players])

        ranked_flights << ranked_flight
      end

      return ranked_flights
    end

    def sort_rank_players_in_flight!(flight_players)
      flight_players.sort! { |x,y| x[:par_related_net_score] <=> y[:par_related_net_score] }
    end

    ##Payouts

    def eligible_players_for_payouts
      Rails.logger.debug { "eligible_players_for_payouts" }

      eligible_player_list = []
      if self.tournament.tournament_days.count == 1
        eligible_player_list = self.tournament.players.map(&:id)
      else #only players that play all days can win
        self.tournament.players.each do |player|
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

      ranked_flights.each do |flight_ranking|
        flight_ranking[:players].each do |p|
          if eligible_player_list.include? p[:id]
            flight = Flight.find(flight_ranking[:flight_id])
            flight.payouts.each_with_index do |payout, i|
              if flight_ranking[:players].count > i
                if payout.payout_results.blank?
                  player = User.find(flight_ranking[:players][i][:id])

                  Rails.logger.info { "Assigning #{player.complete_name} to Payout #{payout.id}" }

                  PayoutResult.create(payout: payout, user: player, flight: flight, tournament_day: flight.tournament_day, amount: payout.amount, points: payout.points)
                else
                  Rails.logger.info { "Already Assigned Payout" }
                end
              end
            end
          else
            Rails.logger.info { "Player Not Eligible: #{p}" }
          end
        end
      end
    end

  end
end
