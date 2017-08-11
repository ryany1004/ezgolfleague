class MoveDuesToLeagueSeason < ActiveRecord::Migration[4.2]
  def change
    change_table :league_seasons do |t|
      t.decimal  "dues_amount", default: 0.0
    end

    League.all.each do |l|
      season = l.league_seasons.last

      unless season.blank?
        season.dues_amount = l.dues_amount
        season.save
      end
    end

    remove_column :leagues, :dues_amount
  end
end
