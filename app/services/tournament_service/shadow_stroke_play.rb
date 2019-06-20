module TournamentService
  module ShadowStrokePlay
    extend self

    def call(tournament_day)
      if tournament_day.base_is_stroke_play?
        tournament_day.scoring_rules.find_by(base_stroke_play: true).destroy
        return
      end

      rule = create_shadow_scoring_rule(tournament_day)
      add_course_holes_to_scoring_rule(tournament_day, rule)
      add_users_to_scoring_rule(tournament_day, rule)
    end

    private

    def create_shadow_scoring_rule(tournament_day)
      StrokePlayScoringRule.find_or_create_by(tournament_day: tournament_day,
                                              base_stroke_play: true,
                                              is_opt_in: false)
    end

    def add_course_holes_to_scoring_rule(tournament_day, scoring_rule)
      scoring_rule.course_holes = tournament_day.course.course_holes
    end

    def add_users_to_scoring_rule(tournament_day, scoring_rule)
      scoring_rule.users = tournament_day.tournament.players_for_day(tournament_day)
    end
  end
end
