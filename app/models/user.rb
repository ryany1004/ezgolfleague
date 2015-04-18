class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable, :registerable
  devise :invitable, :database_authenticatable, :recoverable, :rememberable, :trackable, :validatable
  
  has_attached_file :avatar, :styles => { :medium => "300x300>", :thumb => "100x100", :micro => "50x50" }, :default_url => "/avatar/:style/missing.png"
  validates_attachment_content_type :avatar, :content_type => /\Aimage\/.*\Z/
  
  has_many :league_memberships, :dependent => :destroy
  has_many :leagues, through: :league_memberships
  belongs_to :current_league, :class_name => "League"
  
  validates :email, presence: true
  validates :first_name, presence: true
  validates :last_name, presence: true
  
  attr_accessor :should_invite
  
  paginates_per 50
  
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
  
end
