class User < ActiveRecord::Base
  include Handicapable
  include Servable
  
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable, :registerable
  devise :invitable, :database_authenticatable, :recoverable, :rememberable, :trackable, :validatable
  
  has_many :league_memberships, :dependent => :destroy
  has_many :leagues, through: :league_memberships
  has_many :payout_results, inverse_of: :user, :dependent => :destroy
  has_many :payments, ->{ order 'created_at DESC' }, inverse_of: :user
  has_many :tournament_day_results, inverse_of: :tournament_day, :dependent => :destroy
  belongs_to :current_league, :class_name => "League"
  has_and_belongs_to_many :flights, inverse_of: :users
  has_and_belongs_to_many :golfer_teams, inverse_of: :users
  has_and_belongs_to_many :contests, inverse_of: :users
  
  validates :email, presence: true, uniqueness: true
  validates :first_name, presence: true
  validates :last_name, presence: true
  
  attr_accessor :should_invite
  
  paginates_per 50
  
  #this is to work around a Devise bug
  def after_password_reset; end
  
  def complete_name(shorten_for_print = false)    
    if shorten_for_print == true
      combined_name = "#{self.last_name}, #{self.first_name}"
      shortened_name = ActionController::Base.helpers.truncate(combined_name, length: 20)
      
      return shortened_name
    else
      return "#{self.last_name}, #{self.first_name}"
    end
  end
  
  def short_name
    return "#{self.last_name}, #{self.first_name[0]}"
  end
  
  def requires_additional_profile_data?
    if self.phone_number.blank? and self.street_address_1.blank?
      return true
    else
      return false
    end
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
    return self.payments_for_league(self.selected_league)
  end
  
  def payments_for_league(league)
    league_season_ids = []
    league.league_seasons.each do |l|
      league_season_ids << l.id
    end
    
    tournament_payments = []
    unless league_season_ids.blank?
      league_payments = self.payments.where("league_season_id IN (?)", league_season_ids)
      tournament_payments = self.payments.joins(:tournament).where(tournaments: {league_id: league.id})
    end
    
    contest_ids = []
    self.selected_league.tournaments.each do |t|
      t.tournament_days.each do |d|
        d.contests.each do |c|
          contest_ids << c
        end
      end
    end
    
    unless contest_ids.blank?
      contest_payments = self.payments.where("contest_id IN (?)", contest_ids)
      
      return league_payments + tournament_payments + contest_payments
    else
      return league_payments + tournament_payments
    end
  end
  
  ##Custom Devise
  
  def league_names_string
    league_names = self.leagues.map {|n| n.name}
    
    return league_names.join(", ")
  end
  
  def invite_email_subject
    unless self.leagues.count == 0
      return self.league_names_string + " - You Have Been Invited!"
    else
      return "EZ Golf League - You Have Been Invited!"
    end
  end
  
  # # This method is called internally during the Devise invitation process. We are
  # # using it to allow for a custom email subject. These options get merged into the
  # # internal devise_invitable options. Tread Carefully.
  # def headers_for(action)
  #   logger.info { "Headers For Called: #{action}" }
  #
  #   return {} unless action == :invitation_instructions
  #   { subject: self.invite_email_subject }
  # end

end
