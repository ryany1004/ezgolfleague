class GolferTeam < ActiveRecord::Base
  include Servable
  
  belongs_to :tournament_day
  has_and_belongs_to_many :users
  has_many :golfer_teams, class_name: "GolferTeam", foreign_key: "parent_team_id"
  belongs_to :parent_team, class_name: "GolferTeam"
  
  attr_accessor :requested_tournament_group_id
  
  validate :players_are_valid, on: :update
  def players_are_valid
    other_teams = self.tournament_day.golfer_teams
  
    self.users.each do |u|
      other_teams.each do |other_team|
        if other_team != self
          errors.add(:user_ids, "can't include a user that's already on another team") if other_team.users.include? u
        end
      end
    end
  end
  
  def has_available_space?
    if self.users.count < self.max_players
      return true
    else
      return false
    end
  end

  def rebalance_tournament_groups_for_request 
    tournament_group = self.tournament_day.tournament_groups.find_by_id(self.requested_tournament_group_id)
    
    self.users.each do |u|
      existing_group = self.tournament_day.tournament_group_for_player(u)
      
      if tournament_group.id != existing_group.id
        self.tournament_day.remove_player_from_group(existing_group, u, false) unless existing_group.blank?
            
        self.tournament_day.add_player_to_group(tournament_group, u)
      end
    end
  end

end
