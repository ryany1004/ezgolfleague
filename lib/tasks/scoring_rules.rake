namespace :scoring_rules do
  desc 'Convert Game Type to Scoring Rules'
  task convert_game_type_to_scoring_rules: :environment do
  	TournamentDay.all.each do |d|
      case d.game_type_id
      when 1
        rule = StrokePlayScoringRule.create(is_opt_in: false, tournament_day: d)

        GameTypeMetadatum.all.where(search_key: rule.legacy_use_back_nine_key).update_all(search_key: rule.use_back_nine_key)
      when 2
        rule = MatchPlayScoringRule.create(is_opt_in: false, tournament_day: d)
      when 3
        rule = StablefordScoringRule.create(is_opt_in: false, tournament_day: d)
      when 7
        rule = TwoManScrambleScoringRule.create(is_opt_in: false, tournament_day: d)
      when 8
        rule = FourManScrambleScoringRule.create(is_opt_in: false, tournament_day: d)
      when 10
        rule = TwoManBestBallScoringRule.create(is_opt_in: false, tournament_day: d)
      end

  		raise "No Scoring Rule: #{d.game_type_id}" if rule.blank?

      #move results
      d.flights.each do |flight|
        flight.tournament_day_results.each do |r|
          r.scoring_rule = rule
          r.save
        end
      end

      #move payments
      if d == d.tournament.first_day
        d.tournament.payments.each do |p|
          p.scoring_rule = rule
          p.save
        end
      end

      #add the course holes
      d.legacy_course_holes.each do |hole|
        rule.scoring_rule_course_holes.create(course_hole: hole)
      end

      #add the users
      d.tournament.players_for_day(d).each do |user|
        rule.users << user

        rule.scoring_rule_participations.create(user: user, dues_paid: rule.dues_amount)
      end

  		d.game_type_id = nil
  		d.save

      contests = Contest.where(tournament_day_id: d.id)
      contests.each do |c|
        case c.contest_type
        when 0
          contest_rule = ManualScoringRule.create
        when 1
          contest_rule = ManualScoringRule.create
        when 2
          contest_rule = NetSkinsScoringRule.create
        when 3
          contest_rule = GrossSkinsScoringRule.create
        when 4
          contest_rule = NetLowScoringRule.create
        when 5
          contest_rule = GrossLowScoringRule.create
        when 6
          contest_rule = NetLowScoringRule.create
        when 7
          contest_rule = GrossLowScoringRule.create
        when 8
          contest_rule = TotalSkinsScoringRule.create
        end

        d.scoring_rules << contest_rule

        #users
        c.users.each do |user|
          contest_rule.users << user
        end

        #move payments
        Payment.where(contest_id: c.id).each do |c|
          c.scoring_rule = contest_rule
          c.save
        end

        #convert results
        c.contest_results.each do |r|
          hole = nil
          if r.contest_hole
            scoring_rule_course_hole = contest_rule.scoring_rule_course_holes.where(course_hole: r.contest_hole.course_hole).first
            if scoring_rule_course_hole.blank?
              contest_rule.course_holes << r.contest_hole.course_hole
            end

            hole = contest_rule.scoring_rule_course_holes.where(course_hole: r.contest_hole.course_hole).first
          end

          contest_rule.payout_results.create(user: r.winner, amount: r.payout_amount, points: r.points, detail: r.result_value, scoring_rule_course_hole: hole)
        end
      end
    end
  end
end