namespace :teams_sample do
  desc 'Add Team Sample Data'
  task add: :environment do
  	league = League.find_by_name("Hunter's Test League")
  	league.league_seasons.destroy_all

  	team_season = LeagueSeason.create!(name: "Team Sample", league: league, season_type_raw: 1, starts_at: "2019-01-01", ends_at: "2019-12-31")

  	team_1 = LeagueSeasonTeam.create!(league_season: team_season, name: "Team 1")
  	team_2 = LeagueSeasonTeam.create!(league_season: team_season, name: "Team 2")

  	league.users.each_with_index do |u, i|
  		if i % 2 == 0
  			team_1.users << u
  		else
  			team_2.users << u
  		end
  	end
  end
end