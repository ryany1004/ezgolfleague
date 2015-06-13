class AddGhinToPlauer < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.string :ghin_number
    end
  end
end
