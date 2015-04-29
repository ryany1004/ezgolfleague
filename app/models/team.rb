class Team < ActiveRecord::Base
  belongs_to :tournament_group, inverse_of: :teams
  has_many :golf_outings, inverse_of: :team, :dependent => :destroy
end
