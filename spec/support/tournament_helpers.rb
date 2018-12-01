module TournamentHelpers
  def create_stroke_play_tournament(strokes:)
    golfer_one = create(:user, first_name: "Primary", last_name: "Golfer", email: "golfer_one@test.com")

    league = create(:league)
    league_season = create(:league_season, league: league)

    tournament = create(:stroke_play_tournament, league: league)
    first_day = create(:tournament_day_with_flights, tournament: tournament)
    scoring_rule = create(:individual_stroke_play_scoring_rule, tournament_day: first_day)
    group = create(:tournament_group, tournament_day: first_day)
    payout = create(:payout, scoring_rule: scoring_rule, flight: first_day.flights.last)

    first_day.add_player_to_group(tournament_group: group, user: golfer_one)

    golfer_one_scorecard = first_day.primary_scorecard_for_user(golfer_one)
    self.populate_scorecard(golfer_one_scorecard, strokes)

    scoring_computer = scoring_rule.scoring_computer
    scoring_computer.generate_tournament_day_results
    scoring_computer.assign_payouts

    tournament
  end

  def create_two_person_stroke_play_tournament
    golfer_one = create(:user, first_name: "Primary", last_name: "Golfer", email: "golfer_one@test.com")
    golfer_two = create(:user, first_name: "Secondary", last_name: "Golfer", email: "golfer_two@test.com")

    league = create(:league)
    league_season = create(:league_season, league: league)

    tournament = create(:stroke_play_tournament, league: league)
    first_day = create(:tournament_day_with_flights, tournament: tournament)
    scoring_rule = create(:individual_stroke_play_scoring_rule, tournament_day: first_day)
    group = create(:tournament_group, tournament_day: first_day)

    first_day.add_player_to_group(tournament_group: group, user: golfer_one)
    first_day.add_player_to_group(tournament_group: group, user: golfer_two)

    tournament
  end  

  #TODO: UPDATE
  def create_two_person_scramble_tournament(strokes:)
    golfer_one = create(:user, first_name: "Primary", last_name: "Golfer", email: "golfer_one@test.com")
    golfer_two = create(:user, first_name: "Secondary", last_name: "Golfer", email: "golfer_two@test.com")

    league = create(:league)
    league_season = create(:league_season, league: league)

    tournament = create(:tournament, league: league)
    first_day = create(:tournament_day_with_flights, tournament: tournament, game_type_id: 8)
    #scoring_rule = create(:individual_stroke_play_scoring_rule, tournament_day: first_day)
    group = create(:tournament_group, tournament_day: first_day)

    first_day.add_player_to_group(tournament_group: group, user: golfer_one)
    first_day.add_player_to_group(tournament_group: group, user: golfer_two)

    daily_team = group.daily_teams.first
    daily_team.users << golfer_one
    daily_team.users << golfer_two

    golfer_one_scorecard = first_day.primary_scorecard_for_user(golfer_one)
    self.populate_scorecard(golfer_one_scorecard, strokes)

    golfer_two_scorecard = first_day.primary_scorecard_for_user(golfer_two)
    self.populate_scorecard(golfer_two_scorecard, strokes)

    scoring_computer = scoring_rule.scoring_computer
    scoring_computer.generate_tournament_day_results

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
