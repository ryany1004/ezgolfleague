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

      payout_results = self.tournament_day.reload.payout_results

      payout_results.each do |result|
        tournament_team = self.tournament_day.tournament_team_for_player(result.user)

        unless tournament_team.blank?
          payout_amount = result.amount / 2.0

          tournament_team.users.each do |u|
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

  end
end
