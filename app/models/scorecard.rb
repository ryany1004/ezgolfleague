class Scorecard < ActiveRecord::Base
  belongs_to :golf_outing, inverse_of: :scorecards
  has_many :scores, inverse_of: :scorecard, :dependent => :destroy
end
