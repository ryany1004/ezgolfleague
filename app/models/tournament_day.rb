class TournamentDay < ActiveRecord::Base
  belongs_to :tournament, inverse_of: :tournament_days
  
end
