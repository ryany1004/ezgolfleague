require 'active_record'

module GameTypes
  class TwoManIndividualStrokePlay < GameTypes::IndividualStrokePlay

    def display_name
      return "Two-Man Individual Stroke Play"
    end

    def game_type_id
      return 14
    end

    def show_other_scorecards?
      true
    end

    ##Teams

    def allow_teams
      return GameTypes::TEAMS_REQUIRED
    end

    def show_teams?
      return true
    end

    def number_of_players_per_team
      return 2
    end

    def players_create_teams?
      return false
    end

    def stroke_play_scorecard_for_user_in_team(user, golfer_team, use_handicaps)
      scorecard = TwoManIndividualStrokePlayScorecard.new
      scorecard.user = user
      scorecard.golfer_team = golfer_team
      scorecard.should_use_handicap = use_handicaps
      scorecard.calculate_scores

      return scorecard
    end

    def related_scorecards_for_user(user, only_human_scorecards = false)
      other_scorecards = []

      team = self.tournament_day.golfer_team_for_player(user)
      unless team.blank?
        team.users.each do |u|
          if u != user
            other_scorecards << self.tournament_day.primary_scorecard_for_user(u)
          end
        end
      end

      if only_human_scorecards == false
        net_team_card = self.stroke_play_scorecard_for_user_in_team(user, team, true)
        other_scorecards << net_team_card

        gross_team_card = self.stroke_play_scorecard_for_user_in_team(user, team, false)
        other_scorecards << gross_team_card
      end

      return other_scorecards
    end

    #NOTE: should generalize this
    def assign_payouts_from_scores
      super

      payout_results = self.tournament_day.reload.payout_results

      payout_results.each do |result|
        golfer_team = self.tournament_day.golfer_team_for_player(result.user)

        unless golfer_team.blank?
          payout_amount = result.amount / 2.0

          golfer_team.users.each do |u|
            if u != result.user
              PayoutResult.create(payout: result.payout, user: u, flight: result.flight, tournament_day: result.tournament_day, amount: payout_amount, points: result.points)
            else
              result.amount = payout_amount
              result.save
            end
          end
        else
          Rails.logger.info {"Golfer Team Blank For User ID #{result.user.id}"}
        end
      end
    end

    ##API

    def scorecard_payload_for_scorecard(scorecard)
      scorecard_api = ScorecardAPIBestBall.new
      scorecard_api.tournament_day = self.tournament_day
      scorecard_api.scorecard = scorecard
      scorecard_api.handicap_allowance = self.handicap_allowance(scorecard.golf_outing.user)

      return scorecard_api.scorecard_representation
    end
  end
end
