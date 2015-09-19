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
      
      group = self.tournament_day.tournament_group_for_player(user)
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
    
    def use_back_nine_key
      return "ShouldUseBackNineForTies-T-#{self.tournament_day.id}-GT-#{self.game_type_id}"
    end
    
    def save_setup_details(game_type_options)      
      should_use_back_nine_for_ties = 0
      should_use_back_nine_for_ties = 1 if game_type_options["use_back_9_to_handle_ties"] == 'true'
      
      metadata = GameTypeMetadatum.find_or_create_by(search_key: use_back_nine_key)
      metadata.integer_value = should_use_back_nine_for_ties
      metadata.save
    end
    
    def remove_game_type_options
      metadata = GameTypeMetadatum.where(search_key: use_back_nine_key).first
      metadata.destroy unless metadata.blank?
    end
    
    def use_back_9_to_break_ties?            
      metadata = GameTypeMetadatum.where(search_key: use_back_nine_key).first
      
      if !metadata.blank? && metadata.integer_value == 1
        return true
      else
        return false
      end
    end
    
    def can_be_played?
      return true if self.tournament_day.data_was_imported == true
      
      return false if self.tournament_day.tournament_groups.count == 0
      return false if self.tournament_day.flights.count == 0
      return false if self.tournament_day.course_holes.count == 0
    
      self.tournament.players.each do |p|        
        return self.tournament_day.player_can_be_flighted(p)
      end
    
      return true
    end
  
    def can_be_finalized?
      flight_payouts = 0
    
      self.tournament_day.flights.each do |f|
        flight_payouts += f.payouts.count
      end
    
      if flight_payouts == 0
        return false
      else
        return true
      end
    end
    
    ##Ranking
    
    def sort_rank_players_in_flight!(flight_players)
      if self.use_back_9_to_break_ties?        
        flight_players.sort_by! {|x| [x[:par_related_net_score], x[:back_nine_net_score]]}
      else
        flight_players.sort! { |x,y| x[:par_related_net_score] <=> y[:par_related_net_score] } #NOTE: Not DRY but there's some sort of binding error with just calling super. :-(
      end
    end
    
    ##Scoring
    
    def related_scorecards_for_user(user)
      other_scorecards = []
      
      self.tournament_day.other_group_members(user).each do |player|
        other_scorecards << self.tournament_day.primary_scorecard_for_user(player)
      end
      
      return other_scorecards
    end

  end
end