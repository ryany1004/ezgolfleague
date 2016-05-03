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
        Rails.logger.info {"Result #{result}"}

        golfer_team = self.tournament_day.golfer_team_for_player(result.user)

        Rails.logger.info {"GT #{golfer_team}"}

        unless golfer_team.blank?
          Rails.logger.info {"Team #{golfer_team.id} has #{golfer_team.users.count}"}

          golfer_team.users.each do |u|
            if u != result.user
              Rails.logger.info {"Creating Duplicate Payout for Teammate: #{u.id}"}

              PayoutResult.create(payout: result.payout, user: u, flight: result.flight, tournament_day: result.tournament_day, amount: result.amount, points: result.points)
            else
              Rails.logger.info {"User Already Had Payout - This May Be Normal"}
            end
          end
        else
          Rails.logger.info {"Golfer Team Blank For User ID #{result.user.id}"}
        end
      end
    end

  end
end
