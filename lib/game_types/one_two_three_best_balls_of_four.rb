module GameTypes
  class OneTwoThreeBestBallsOfFour < GameTypes::BestBall
    
    def display_name
      return "One-Two-Three Best Balls of Four"
    end
    
    def game_type_id
      return 13
    end
    
    ##Setup
    
    def setup_partial
      return "shared/game_type_setup/one_two_three_best_balls_of_four"
    end
    
    def best_ball_par_percentage_for_ball(ball_number)
      return "BestBallPar-#{ball_number}-T-#{self.tournament_day.id}-GT-#{self.game_type_id}"
    end
    
    def save_setup_details(game_type_options)
      self.save_best_ball_selection("1", game_type_options["best_ball_1"])
      self.save_best_ball_selection("2", game_type_options["best_ball_2"])
      self.save_best_ball_selection("3", game_type_options["best_ball_3"])
    end
    
    def save_best_ball_selection(ball_number, par_value)
      metadata = GameTypeMetadatum.find_or_create_by(search_key: best_ball_par_percentage_for_ball(ball_number))
      metadata.integer_value = par_value
      metadata.save
    end
    
    def remove_game_type_options
      metadata = GameTypeMetadatum.where(search_key: best_ball_par_percentage_for_ball("1")).first
      metadata.destroy unless metadata.blank?
      
      metadata = GameTypeMetadatum.where(search_key: best_ball_par_percentage_for_ball("2")).first
      metadata.destroy unless metadata.blank?
      
      metadata = GameTypeMetadatum.where(search_key: best_ball_par_percentage_for_ball("3")).first
      metadata.destroy unless metadata.blank?
    end
    
    def selection_options
      return ["3", "4", "5"]
    end
    
    def current_selection_for_ball_number(ball_number)
      metadata = GameTypeMetadatum.where(search_key: best_ball_par_percentage_for_ball(ball_number)).first
      
      if metadata.blank?
        if ball_number == "1"
          return "5"
        elsif ball_number == "2"
          return "4"
        elsif ball_number == "3"
          return "3"
        end
      else
        return metadata.integer_value.to_s
      end
    end
    
    def current_one_selection
      return current_selection_for_ball_number("1")
    end
    
    def current_two_selection
      return current_selection_for_ball_number("2")
    end
    
    def current_three_selection
      return current_selection_for_ball_number("3")
    end
    
    ##Teams

    def number_of_players_per_team
      return 4
    end

    def best_ball_scorecard_for_user_in_team(user, tournament_team, use_handicaps)
      scorecard = OneTwoThreeBestBallScorecard.new
      scorecard.user = user
      scorecard.tournament_team = tournament_team
      scorecard.should_use_handicap = use_handicaps
      scorecard.calculate_scores

      return scorecard
    end

    ##Scoring
    
    def assign_payouts_from_scores
      super
    
      Rails.logger.info { "Assigning Team Scores" }
    
      self.tournament_day.reload
      
      self.tournament_day.payout_results.each do |result|
        team = self.tournament_day.tournament_team_for_player(result.user)

        unless team.blank?
          team.users.where("id != ?", result.user.id).each do |teammate|
            Rails.logger.info { "123BB4 Teams: Assigning #{teammate.complete_name} to Payout #{result.id}" }

            PayoutResult.create(payout: result.payout, user: teammate, flight: result.flight, tournament_day: self.tournament_day, amount: result.amount, points: result.points)
          end
        end
      end
    end

  end
end