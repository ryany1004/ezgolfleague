class CreateTournamentDays < ActiveRecord::Migration
  def change
    create_table :tournament_days do |t|

      t.timestamps null: false
    end
    
    #move tournament groups
    #move flights
    #move course
    #move tournament_at
    #move game type
  end
end
