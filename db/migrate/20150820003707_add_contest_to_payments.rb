class AddContestToPayments < ActiveRecord::Migration
  def change
    change_table :payments do |t|
      t.integer :contest_id
    end
  end
end
