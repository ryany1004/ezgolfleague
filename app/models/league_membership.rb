class LeagueMembership < ActiveRecord::Base
  belongs_to :league
  belongs_to :user

  validates :league, presence: true
  validates :user, presence: true
  validates :league, uniqueness: { scope: :user }

  paginates_per 50

  before_create :setup_initial_state

  def setup_initial_state
    self.state = MembershipStates::ADDED
  end

end
