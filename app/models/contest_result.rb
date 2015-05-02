class ContestResult < ActiveRecord::Base
  belongs_to :contest
  belongs_to :contest_hole
  belongs_to :winner, :class_name => "User", :foreign_key => "winner_id"
  
end
