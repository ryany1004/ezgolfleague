module TournamentService
  module ShadowStrokePlay
    extend self

    def call(tournament_day)
      create_shadow_scoring_rule(tournament_day) if tournament_day.stroke_play_scoring_rule.blank?
    end

    private

    def create_shadow_scoring_rule(tournament_day)
      Rails.logger.info { 'Creating a Shadow Stroke Play Tournament for Day' }

      scoring_rule = StrokePlayScoringRule.create(tournament_day: tournament_day,
                                                  base_stroke_play: true,
                                                  is_opt_in: false)

      tournament_day.course.course_holes.each do |ch|
        scoring_rule.course_holes << ch
      end

      tournament_day.tournament.players_for_day(tournament_day).each do |u|
        scoring_rule.users << u unless scoring_rule.users.include? u
      end
    end
  end
end
