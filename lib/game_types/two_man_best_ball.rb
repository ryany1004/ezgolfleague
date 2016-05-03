module GameTypes
  class TwoManBestBall < GameTypes::BestBall

    def display_name
      return "Two-Man Best Ball"
    end

    def game_type_id
      return 10
    end

    ##Teams

    def number_of_players_per_team
      return 2
    end

    def assign_payouts_from_scores
      super

      payout_results = self.tournament_day.payout_results

      Rails.logger.info {"Copying #{payout_results.count} Payouts to Teammates"}

      payout_results.each do |result|
        golfer_team = last_day.golfer_team_for_player(result.user)

        unless golfer_team.blank?
          golfer_team.users.each do |u|
            if u != result.user
              PayoutResult.create(payout: result.payout, user: u, flight: result.flight, tournament_day: result.tournament_day, amount: result.amount, points: result.points)
            end
          end
        end
      end
    end

  end
end
