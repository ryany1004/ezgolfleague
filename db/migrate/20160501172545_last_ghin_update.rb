class LastGhinUpdate < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.datetime :ghin_updated_at
    end
  end
end
