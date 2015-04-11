class TournamentGroup < ActiveRecord::Base
  belongs_to :tournament, inverse_of: :tournament_groups
  has_many :teams, inverse_of: :tournament_group, :dependent => :destroy
end
