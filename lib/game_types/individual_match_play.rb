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
    
    def team_scorecard_for_team(golfer_team)
      scorecard = IndividualMatchPlayScorecard.new
      scorecard.golfer_team = golfer_team
      scorecard.calculate_scores
      
      return scorecard
    end
    
    ##Handicap
    
    def handicap_allowance(user) #TODO
      return []
    end
    
    ##Scoring

    def player_points(user) #TODO
      return 0
    end
    
    def related_scorecards_for_user(user)      
      other_scorecards = []
      
      team = self.tournament.golfer_team_for_player(user)
      unless team.blank?
        team.users.each do |u|
          other_scorecards << self.tournament.primary_scorecard_for_user(u) if u != user
        end
      
        # team_scorecard = self.tournament.game_type.team_scorecard_for_team(team)
        # other_scorecards << team_scorecard unless team_scorecard.blank?
      end
      
      return other_scorecards
    end

  end
end