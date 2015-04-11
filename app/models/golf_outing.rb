class GolfOuting < ActiveRecord::Base
  belongs_to :team, inverse_of: :golf_outings
  has_one :user
  has_many :scorecards, inverse_of: :golf_outing, :dependent => :destroy
end
