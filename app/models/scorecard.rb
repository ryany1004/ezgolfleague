class Scorecard < ActiveRecord::Base
  belongs_to :golf_outing, inverse_of: :scorecards
  has_many :scores, -> { order("sort_order") }, inverse_of: :scorecard, :dependent => :destroy
  
  accepts_nested_attributes_for :scores
end
