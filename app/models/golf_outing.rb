class GolfOuting < ActiveRecord::Base
  belongs_to :team, inverse_of: :golf_outings
  belongs_to :user
  has_many :scorecards, inverse_of: :golf_outing, :dependent => :destroy
end
