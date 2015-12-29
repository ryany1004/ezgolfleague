class Team < ActiveRecord::Base
  include Servable
  
  belongs_to :tournament_group, inverse_of: :teams
  has_many :golf_outings, inverse_of: :team, :dependent => :destroy
end

#Note that these are distinct from GolferTeams due to legacy naming issues. That's probably the model you are looking for...