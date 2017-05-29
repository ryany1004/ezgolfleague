class TournamentDayResult < ActiveRecord::Base
  belongs_to :tournament_day, inverse_of: :tournament_day_results, touch: true
  belongs_to :user, inverse_of: :tournament_day_results, touch: true
  belongs_to :primary_scorecard, :class_name => "Scorecard", :foreign_key => "user_primary_scorecard_id", touch: true
  belongs_to :flight, inverse_of: :tournament_day_results
end
