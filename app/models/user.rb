class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable, :registerable
  devise :database_authenticatable, :recoverable, :rememberable, :trackable, :validatable
  
  has_attached_file :avatar, :styles => { :medium => "300x300>", :thumb => "100x100", :micro => "50x50" }, :default_url => "/avatar/:style/missing.png"
  validates_attachment_content_type :avatar, :content_type => /\Aimage\/.*\Z/
  
  has_many :leagues, through: :league_memberships
  
  validates :email, presence: true
  validates :first_name, presence: true
  validates :last_name, presence: true
  
  paginates_per 50
  
  def complete_name
    return "#{self.last_name}, #{self.first_name}"
  end
  
end
