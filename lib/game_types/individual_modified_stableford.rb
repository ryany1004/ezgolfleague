module GameTypes
  class IndividualModifiedStableford < GameTypes::IndividualStrokePlay

    def display_name
      return "Individual Modified Stableford"
    end

    def game_type_id
      return 3
    end

    ## Scoring

    def compute_player_score(user, use_handicap = true, holes = [])
      if !self.tournament.includes_player?(user)
        Rails.logger.info { "Tournament Does Not Include Player: #{user.complete_name}" }

        return nil
      end

      total_score = 0

      scorecard = self.stableford_scorecard_for_user(user)
      return 0 if scorecard.blank? || scorecard.scores.blank?

      scorecard.scores.each do |score|
        should_include_score = true #allows us to calculate partial scores, i.e. back 9
        if holes.blank? == false
          should_include_score = false if !holes.include? score.course_hole.hole_number
        end

        if should_include_score == true
          hole_score = score.strokes

          total_score = total_score + hole_score
        end
      end

      total_score = 0 if total_score < 0

      Rails.logger.debug { "Stableford Computed: #{total_score}. User: #{user.complete_name} holes: #{holes}" }

      return total_score
    end

    def related_scorecards_for_user(user, only_human_scorecards = false)
      other_scorecards = []

      other_scorecards << self.stableford_scorecard_for_user(user, self.tournament_day.tournament_group_for_player(user)) if only_human_scorecards == false

      self.tournament_day.other_group_members(user).each do |player|
        other_scorecards << self.tournament_day.primary_scorecard_for_user(player)
        other_scorecards << self.stableford_scorecard_for_user(player, self.tournament_day.tournament_group_for_player(player)) if only_human_scorecards == false
      end

      return other_scorecards
    end

    def stableford_scorecard_for_user(user)
      scorecard = IndividualStablefordScorecard.new
      scorecard.user = user
      scorecard.underlying_tournament_day = self.tournament_day
      scorecard.calculate_scores

      return scorecard
    end

    ##Ranking

    def sort_rank_players_in_flight!(flight_players)
      flight_players.sort! { |x,y| y[:par_related_net_score] <=> x[:par_related_net_score] }
    end

  end
end
