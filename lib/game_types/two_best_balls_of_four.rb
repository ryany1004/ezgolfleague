module GameTypes
  class TwoBestBallsOfFour < GameTypes::BestBall
    
    def display_name
      return "Two Best Balls of Four"
    end
    
    def game_type_id
      return 11
    end
    
    ##Teams

    def number_of_players_per_team
      return 4
    end

    def best_ball_scorecard_for_user_in_team(user, tournament_team, use_handicaps)
      scorecard = TwoBestBallScorecard.new
      scorecard.user = user
      scorecard.tournament_team = tournament_team
      scorecard.should_use_handicap = use_handicaps
      scorecard.calculate_scores

      return scorecard
    end

  end
end