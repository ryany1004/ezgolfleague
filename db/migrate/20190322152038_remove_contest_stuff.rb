class Contest < ApplicationRecord
end

class ContestHole < ApplicationRecord
end

class ContestResult < ApplicationRecord
end

class RemoveContestStuff < ActiveRecord::Migration[5.2]
  def change
  	drop_table :contests
  	drop_table :contest_holes
  	drop_table :contest_results
  end
end
