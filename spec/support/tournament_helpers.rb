module TournamentHelpers
  def create_stroke_play_tournament(strokes:)
    golfer_one = create(:user, first_name: "Primary", last_name: "Golfer", email: "golfer_one@test.com")

    league = create(:league)
    league_season = create(:league_season, league: league)

    tournament = create(:stroke_play_tournament, league: league)
    first_day = create(:tournament_day_with_flights, tournament: tournament)
    group = create(:tournament_group, tournament_day: first_day)

    first_day.add_player_to_group(group, golfer_one)

    golfer_one_scorecard = first_day.primary_scorecard_for_user(golfer_one)
    self.populate_scorecard(golfer_one_scorecard, strokes)

    first_day.score_users

    tournament
  end

  def create_two_person_stroke_play_tournament
    golfer_one = create(:user, first_name: "Primary", last_name: "Golfer", email: "golfer_one@test.com")
    golfer_two = create(:user, first_name: "Secondary", last_name: "Golfer", email: "golfer_two@test.com")

    league = create(:league)
    league_season = create(:league_season, league: league)

    tournament = create(:stroke_play_tournament, league: league)
    first_day = create(:tournament_day_with_flights, tournament: tournament)
    group = create(:tournament_group, tournament_day: first_day)

    first_day.add_player_to_group(group, golfer_one)
    first_day.add_player_to_group(group, golfer_two)

    tournament
  end  

  def create_two_person_scramble_tournament(strokes:)
    golfer_one = create(:user, first_name: "Primary", last_name: "Golfer", email: "golfer_one@test.com")
    golfer_two = create(:user, first_name: "Secondary", last_name: "Golfer", email: "golfer_two@test.com")

    league = create(:league)
    league_season = create(:league_season, league: league)

    tournament = create(:tournament, league: league)
    first_day = create(:tournament_day_with_flights, tournament: tournament, game_type_id: 8)
    group = create(:tournament_group, tournament_day: first_day)

    first_day.add_player_to_group(group, golfer_one)
    first_day.add_player_to_group(group, golfer_two)

    golfer_team = group.golfer_teams.first
    golfer_team.users << golfer_one
    golfer_team.users << golfer_two

    golfer_one_scorecard = first_day.primary_scorecard_for_user(golfer_one)
    self.populate_scorecard(golfer_one_scorecard, strokes)

    golfer_two_scorecard = first_day.primary_scorecard_for_user(golfer_two)
    self.populate_scorecard(golfer_two_scorecard, strokes)

    first_day.score_users

    tournament
  end

  def create_match_play_tournament
  end

  def create_stableford_tournament
  end

  def populate_scorecard(scorecard, strokes)
    scorecard.scores.each_with_index do |s, i|
      s.strokes = strokes[i]
      s.save
    end
  end
end

RSpec.configure do |c|
  c.include TournamentHelpers
end
