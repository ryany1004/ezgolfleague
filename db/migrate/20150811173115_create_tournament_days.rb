class CreateTournamentDays < ActiveRecord::Migration
  def change
    create_table :tournament_days do |t|
      t.integer :tournament_id
      t.integer :course_id
      t.integer :game_type_id
      t.datetime :tournament_at
      t.timestamps null: false
    end

    add_column :tournament_groups, :tournament_day_id, :integer
    add_column :flights, :tournament_day_id, :integer
    add_column :contests, :tournament_day_id, :integer
    add_column :golfer_teams, :tournament_day_id, :integer
    
    create_table :course_holes_tournament_days, id: false do |t|
      t.belongs_to :course_hole, index: true
      t.belongs_to :tournament_day, index: true
    end
        
    Tournament.all.each do |t|
      day = TournamentDay.new(tournament: t, course_id: t.course_id, game_type_id: t.game_type_id, tournament_at: t.tournament_at)
      day.skip_date_validation = true
      day.save!
      
      TournamentGroup.where(tournament_id: t.id).each do |group|
        group.tournament_day_id = day.id
        group.save
      end
      
      Flight.where(tournament_id: t.id).each do |flight|
        flight.tournament_day_id = day.id
        flight.save
      end
      
      Contest.where(tournament_id: t.id).each do |contest|
        contest.tournament_day_id = day.id
        contest.save
      end
      
      GolferTeam.where(tournament_id: t.id).each do |golfer_team|
        golfer_team.tournament_day_id = day.id
        golfer_team.save
      end

      Course.where(id: t.course_id).first.course_holes.each do |hole|
        day.course_holes << hole
      end
      
      if day.game_type_id == 1
        metadata = GameTypeMetadatum.find_or_create_by(search_key: day.game_type.use_back_nine_key)
        metadata.integer_value = 1
        metadata.save
      end
    end
    
    remove_column :tournaments, :course_id
    remove_column :tournaments, :tournament_at
    remove_column :tournaments, :game_type_id
    
    remove_column :tournament_groups, :tournament_id
    remove_column :flights, :tournament_id
    remove_column :contests, :tournament_id
    remove_column :golfer_teams, :tournament_id
    
    drop_table :course_holes_tournaments
  end
  
  #TODO: Importers
  
end