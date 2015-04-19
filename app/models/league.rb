class League < ActiveRecord::Base
  has_many :league_memberships, :dependent => :destroy
  has_many :users, through: :league_memberships
  has_many :tournaments, :dependent => :destroy, inverse_of: :league
  
  validates :name, presence: true
  
  paginates_per 50
  
  def membership_for_user(user)
    return self.league_memberships.where(user: user).first
  end
  
  def state_for_user(user)
    membership = self.membership_for_user(user)
    
    return membership.state
  end
  
  def ranked_users_for_year(year)
    ranked_players = []
    
    year_date = Date.parse("#{year}-01-01")
    tournaments = Tournament.where(league: self).where("tournament_at >= ? AND tournament_at <= ?", year_date.at_beginning_of_year, year_date.at_end_of_year).includes(tournament_groups: [teams: :golf_outings])
    
    tournaments.each do |t|
      t.players.each do |p|
        points = t.player_points(p)
      
        found_existing_player = false
        
        ranked_players.each do |r|
          if r[:id] == p.id
            r[:points] = r[:points] + points
            
            found_existing_player = true
          end
        end
      
        if found_existing_player == false
          ranked_players << { id: p.id, name: p.complete_name, points: points }
        end
      end
    end
    
    ranked_players.sort! { |x,y| y[:points] <=> x[:points] }
    
    return ranked_players
  end
  
end
