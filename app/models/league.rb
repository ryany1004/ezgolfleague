class League < ActiveRecord::Base
  has_many :league_memberships, :dependent => :destroy
  has_many :users, through: :league_memberships
  
  validates :name, presence: true
  
  paginates_per 50
  
  def membership_for_user(user)
    return self.league_memberships.where(user: user).first
  end
  
  def state_for_user(user)
    membership = self.membership_for_user(user)
    
    return membership.state
  end
  
end
