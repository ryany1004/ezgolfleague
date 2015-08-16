class AddNewIndexesForPerformance < ActiveRecord::Migration
  def change
    add_index :tournament_groups, :tournament_day_id
    add_index :flights, :tournament_day_id
    add_index :contests, :tournament_day_id
    add_index :golfer_teams, :tournament_day_id
    
    add_index :tournament_days, :tournament_at
    add_index :scores, :sort_order
    add_index :payouts, :sort_order
    
    add_index :flights, :flight_number
    add_index :flights, :course_tee_box_id
    
    add_index :golf_outings, :course_tee_box_id
    
    add_index :contest_holes, :contest_id
    add_index :contest_holes, :course_hole_id
    add_index :contest_results, :contest_id
    add_index :contest_results, :contest_hole_id
    add_index :contest_results, :winner_id
    
    add_index :course_hole_tee_boxes, :course_tee_box_id
  end
end
