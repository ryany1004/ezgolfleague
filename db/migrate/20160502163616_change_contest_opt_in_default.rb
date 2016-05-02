class ChangeContestOptInDefault < ActiveRecord::Migration
  def change
    change_column_default :contests, :is_opt_in, false
  end
end
