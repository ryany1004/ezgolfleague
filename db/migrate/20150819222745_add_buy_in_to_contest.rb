class AddBuyInToContest < ActiveRecord::Migration
  def change
    change_table :contests do |t|
      t.decimal :dues_amount, :default => 0.0
    end
    
    create_table "contests_users", id: false, force: :cascade do |t|
      t.integer "contest_id"
      t.integer "user_id"
    end
    
  end
end
