class LeagueMembership < ApplicationRecord
  scope :active, -> { where(state: MembershipStates::ACTIVE_FOR_BILLING) }

  belongs_to :league, touch: true
  belongs_to :user, inverse_of: :league_memberships

  validates :league, presence: true
  validates :user, presence: true
  validates :league, uniqueness: { scope: :user }

  paginates_per 50

  before_create :setup_initial_state
  after_initialize :setup_toggle_state

  attr_accessor :toggle_active

  def setup_initial_state
    self.state = MembershipStates::ADDED
  end

  def expire
    update(state: MembershipStates::EXPIRED)
  end

  def setup_toggle_state
    if self.state == MembershipStates::ACTIVE_FOR_BILLING
      self.toggle_active = true
    else
      self.toggle_active = false
    end
  end
end
