module GameTypes
  class IndividualStrokePlay < GameTypes::GameTypeBase
    include Rails.application.routes.url_helpers

    def display_name
      return "Individual Stroke Play"
    end
    
    def game_type_id
      return 1
    end

    def other_group_members(user)
      other_members = []
      
      group = self.tournament.tournament_group_for_player(user)
      group.teams.each do |team|
        team.golf_outings.each do |outing|
          other_members << outing.user if outing.user != user
        end
      end
      
      return other_members
    end
    
    def user_is_in_group?(user, tournament_group)
      tournament_group.teams.each do |team|
        team.golf_outings.each do |outing|
          return true if user == outing.user
        end
      end
      
      return false
    end
    
    ##Setup
    
    def setup_partial
      return "shared/game_type_setup/individual_stroke_play"
    end
    
    def save_setup_details
      #do nothing
    end
    
    def can_be_played?
      return false if self.tournament.tournament_groups.count == 0
      return false if self.tournament.flights.count == 0
    
      self.tournament.players.each do |p|
        return false if self.tournament.flight_for_player(p) == nil
      end
    
      return true
    end
  
    def can_be_finalized?
      flight_payouts = 0
    
      self.tournament.flights.each do |f|
        flight_payouts += f.payouts.count
      end
    
      if flight_payouts == 0
        return false
      else
        return true
      end
    end
    
    ##Scoring
    
    def related_scorecards_for_user(user)
      other_scorecards = []
      
      self.tournament.other_group_members(user).each do |player|
        other_scorecards << self.tournament.primary_scorecard_for_user(player)
      end
      
      return other_scorecards
    end

  end
end