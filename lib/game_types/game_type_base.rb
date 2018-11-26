module GameTypes
  TEAMS_ALLOWED = "Allowed"
  TEAMS_REQUIRED = "Required"
  TEAMS_DISALLOWED = "Disallowed"

  VARIABLE = -1

  class GameTypeBase
    include Rails.application.routes.url_helpers

    attr_accessor :tournament_day

    def self.available_types
      [
        GameTypes::IndividualStrokePlay.new,
        GameTypes::TwoManIndividualStrokePlay.new,
        GameTypes::IndividualModifiedStableford.new,
        GameTypes::TwoManScramble.new,
        GameTypes::FourManScramble.new,
        GameTypes::TwoManBestBall.new,
      ]
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
      # flight_payouts = 0
      # self.tournament_day.flights.each do |f|
      #   flight_payouts += f.payouts.count
      # end

      # broken_contests = 0
      # self.tournament_day.tournament.tournament_days.includes(:contests).each do |day|
      #   day.contests.each do |c|
      #     broken_contests += 1 if c.contest_can_be_scored? == false
      #   end
      # end

      # players = 0
      # players = self.tournament_day.tournament.players.count

      # has_scores = false
      # has_scores = self.tournament_day.has_scores?

      # if flight_payouts == 0 or broken_contests > 0 or players == 0 or has_scores == false
      #   false
      # else
      #   true
      # end

      false
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
      nil
    end

    def user_is_in_group?(user, tournament_group)
      false
    end

    ##Teams

    def allow_teams
      GameTypes::TEAMS_DISALLOWED
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

    # def after_updating_scores_for_scorecard(scorecard)
    #   #nada
    # end

    # def related_scorecards_for_user(user, only_human_scorecards = false)
    #   return []
    # end

    # def player_score(user, use_handicap = true, holes = [])
    #   0
    # end

    # def compute_stroke_play_player_score(user, use_handicap = true, holes = [])
    #   0
    # end

    # def compute_player_score(user, use_handicap = true, holes = [])
    #   nil
    # end

    # def compute_adjusted_player_score(user)
    #   0
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

    # def scorecard_payload_for_scorecard(scorecard)
    #   scorecard_api = ScorecardAPIBase.new
    #   scorecard_api.tournament_day = self.tournament_day
    #   scorecard_api.scorecard = scorecard
    #   scorecard_api.handicap_allowance = self.handicap_allowance(scorecard.golf_outing.user)

    #   return scorecard_api.scorecard_representation
    # end

    ##Handicap

    # def course_handicap_for_game_type(golf_outing)
    #   return golf_outing.course_handicap
    # end

    # def handicap_allowance(user)
    #   golf_outing = self.tournament_day.golf_outing_for_player(user)
    #   return nil if golf_outing.blank? #did not play

    #   course_handicap = self.course_handicap_for_game_type(golf_outing)

    #   ##
    #   allowance = Rails.cache.fetch("golf_outing#{golf_outing.id}-#{golf_outing.updated_at.to_i}", expires_in: 15.minute, race_condition_ttl: 10) do
    #     return nil if golf_outing.course_tee_box.blank?

    #     Rails.logger.debug { "Course Handicap: #{course_handicap}" }

    #     if golf_outing.course_tee_box.tee_box_gender == "Men"
    #       sorted_course_holes_by_handicap = self.tournament_day.course_holes.reorder("mens_handicap")
    #     else
    #       sorted_course_holes_by_handicap = self.tournament_day.course_holes.reorder("womens_handicap")
    #     end

    #     if !course_handicap.blank?
    #       allowance = []
    #       while course_handicap > 0 do
    #         sorted_course_holes_by_handicap.each do |hole|
    #           existing_hole = nil

    #           allowance.each do |a|
    #             if hole == a[:course_hole]
    #               existing_hole = a
    #             end
    #           end

    #           if existing_hole.blank?
    #             existing_hole = {course_hole: hole, strokes: 0}
    #             allowance << existing_hole
    #           end

    #           if course_handicap > 0
    #             existing_hole[:strokes] = existing_hole[:strokes] + 1
    #             course_handicap = course_handicap - 1
    #           end
    #         end
    #       end

    #       allowance
    #     else
    #       nil
    #     end
    #   end

    #   allowance
    # end

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

    # def flights_with_rankings
    #   self.tournament_day.flights.includes(:users, :tournament_day_results, :payout_results)
    # end

    ##Payouts

    # def eligible_players_for_payouts
    #   Rails.logger.debug { "eligible_players_for_payouts" }

    #   eligible_player_list = []
    #   if self.tournament.tournament_days.count == 1
    #     eligible_player_list = self.tournament.qualified_players.map(&:id)
    #   else #only players that play all days can win
    #     self.tournament.qualified_players.each do |player|
    #       player_played_all_days = true

    #       self.tournament.tournament_days.each do |day|
    #         player_played_all_days = false if self.tournament.includes_player?(player, day) == false
    #       end

    #       eligible_player_list << player.id if player_played_all_days == true
    #     end
    #   end

    #   Rails.logger.debug { "Completed eligible_players_for_payouts" }

    #   eligible_player_list
    # end

    # def assign_payouts_from_scores
    #   self.tournament_day.payout_results.destroy_all

    #   payout_count = 0
    #   self.tournament_day.flights.each do |flight|
    #     payout_count += flight.payouts.count
    #   end

    #   Rails.logger.info { "Payouts: #{payout_count}" }

    #   return if payout_count == 0

    #   if self.tournament.tournament_days.count > 1 && self.tournament_day == self.tournament.last_day
    #     eligible_player_list = self.eligible_players_for_payouts

    #     rankings = []
    #     self.tournament.tournament_days.each do |day|
    #       rankings << day.flights_with_rankings
    #     end

    #     ranked_flights = self.tournament.combine_rankings(rankings)
    #   else
    #     eligible_player_list = self.tournament.players.map(&:id)

    #     ranked_flights = self.flights_with_rankings
    #   end

    #   ranked_flights.each do |flight|
    #     flight.payouts.each_with_index do |payout, i|
    #       if payout.payout_results.count == 0
    #         result = flight.tournament_day_results[i]
    #         if result.present? and eligible_player_list.include? result.user.id
    #           player = result.user

    #           Rails.logger.info { "Assigning #{player.complete_name} to Payout #{payout.id}. Result ID: #{result.id}" }

    #           PayoutResult.create(payout: payout, user: player, flight: flight, tournament_day: flight.tournament_day, amount: payout.amount, points: payout.points)
    #         end
    #       else
    #         Rails.logger.info { "Payout Already Has Results: #{payout.payout_results.map(&:id)}" }
    #       end
    #     end
    #   end
    # end

  end
end
