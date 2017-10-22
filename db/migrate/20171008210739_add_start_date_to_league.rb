class AddStartDateToLeague < ActiveRecord::Migration[5.1]
  def change
  	change_table :leagues do |t|
      t.date :start_date
    end
  end
end
