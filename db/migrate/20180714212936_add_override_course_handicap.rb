class AddOverrideCourseHandicap < ActiveRecord::Migration[5.1]
  def change
		change_table :league_memberships do |t|
			t.float :course_handicap
		end
  end
end
