class User < ActiveRecord::Base
  include Handicapable
  
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable, :registerable
  devise :invitable, :database_authenticatable, :recoverable, :rememberable, :trackable, :validatable
  
  has_many :league_memberships, :dependent => :destroy
  has_many :leagues, through: :league_memberships
  has_many :payouts, inverse_of: :user
  has_many :payments, inverse_of: :user
  has_many :tournament_day_results, inverse_of: :tournament_day, :dependent => :destroy
  belongs_to :current_league, :class_name => "League"
  has_and_belongs_to_many :flights, inverse_of: :users
  has_and_belongs_to_many :golfer_teams, inverse_of: :users
  
  validates :email, presence: true, uniqueness: true
  validates :first_name, presence: true
  validates :last_name, presence: true
  
  attr_accessor :should_invite
  
  paginates_per 50
  
  #this is to work around a Devise bug
  def after_password_reset; end
  
  def complete_name
    return "#{self.last_name}, #{self.first_name}"
  end
  
  def selected_league
    unless self.current_league.blank?
      return self.current_league
    else
      return self.leagues.first
    end
  end
  
  def is_any_league_admin?
    return true if self.is_super_user
    return false if self.blank?
    
    self.leagues.each do |league|
      membership = league.membership_for_user(self)
    
      unless membership.blank?
        return membership.is_admin
      else
        return false
      end
    end
    
    return false
  end
  
  def is_member_of_league?(league)  
    if self.league_memberships.where("league_id = ?", league.id).blank?
      return false
    else
      return true
    end
  end
  
  def payments_for_current_league    
    league_payments = self.payments.where("league_id = ?", self.selected_league.id)
    tournament_payments = self.payments.joins(:tournament).where(tournaments: {league_id: self.selected_league.id})

    return league_payments + tournament_payments
  end

end
