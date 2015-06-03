module GameTypes
  class IndividualMatchPlay < GameTypes::GameTypeBase

    def display_name
      return "Individual Match Play"
    end
    
    def game_type_id
      return 2
    end
    
    ##Setup
    
    def can_be_played?
      return false if self.tournament.tournament_groups.count == 0
      return false if self.tournament.flights.count == 0
    
      self.tournament.players.each do |p|
        return false if self.tournament.golfer_team_for_player(p) == nil
      end
    
      return true
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
    
    def match_play_scorecard_for_user_in_team(user, golfer_team)
      scorecard = IndividualMatchPlayScorecard.new
      scorecard.user = user
      scorecard.golfer_team = golfer_team
      scorecard.calculate_scores

      return scorecard
    end
    
    ##Handicap
    
    def handicap_allowance(user) #TODO
      return []
    end
    
    ##Scoring
    
    def flights_with_rankings #TODO
      return []
    end

    def player_points(user) #TODO
      return 0
    end
    
    def related_scorecards_for_user(user)      
      other_scorecards = []
      
      team = self.tournament.golfer_team_for_player(user)
      unless team.blank?
        user_match_play_card = self.match_play_scorecard_for_user_in_team(user, team)
        other_scorecards << user_match_play_card
        
        team.users.each do |u|
          if u != user
            other_scorecards << self.tournament.primary_scorecard_for_user(u) 
          
            other_user_match_play_card = self.match_play_scorecard_for_user_in_team(u, team)
            other_scorecards << other_user_match_play_card
          end
        end
      end
            
      return other_scorecards
    end

  end
end