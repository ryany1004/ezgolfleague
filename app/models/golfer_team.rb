class GolferTeam < ActiveRecord::Base
  belongs_to :tournament
  has_and_belongs_to_many :users
  
  def has_available_space?
    if self.users.count < self.max_players
      return true
    else
      return false
    end
  end
  
end
