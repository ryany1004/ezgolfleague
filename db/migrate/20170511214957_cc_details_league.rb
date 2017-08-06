class CcDetailsLeague < ActiveRecord::Migration[4.2]
  def change
    change_table :leagues do |t|
      t.string :cc_last_four
      t.integer :cc_expire_month
      t.integer :cc_expire_year
    end
  end
end
