module HandicapComputers
  class ScrambleHandicapComputer < BaseHandicapComputer
    def course_handicap_for_game_type(golf_outing)
      team_adjusted_course_handicap = 0.0

      team_adjusted_course_handicap += super(golf_outing)

      @scoring_rule.other_group_members(user: golf_outing.user).each do |u|
        user_golf_outing = self.tournament_day.golf_outing_for_player(u)

        unless user_golf_outing.blank?
          team_adjusted_course_handicap += super(user_golf_outing)
        end
      end

      # apply percentage
      percentage = @scoring_rule.current_handicap_percentage.to_f
      if percentage > 0.0
        percentage = percentage / 100.0
      else
        percentage = 1.0
      end

      Rails.logger.debug { "Scramble: Adjusting team handicap from #{team_adjusted_course_handicap} with percentage: #{percentage}" }

      team_adjusted_course_handicap = (team_adjusted_course_handicap * percentage)

      Rails.logger.debug { "Scramble team handicap: #{team_adjusted_course_handicap}" }

      team_adjusted_course_handicap
    end
  end
end
