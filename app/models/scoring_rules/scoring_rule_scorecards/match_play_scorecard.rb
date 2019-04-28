module ScoringRuleScorecards
  module MatchPlayScorecardResult
    WON = 1
    LOST = 2
    TIED = 3
    INCOMPLETE = 4
  end

  class MatchPlayScorecard < ScoringRuleScorecards::BaseScorecard
    attr_accessor :opponent
    attr_accessor :running_score
    attr_accessor :opponent_running_score
    attr_accessor :unplayed_holes
    attr_accessor :holes_won

    def name(_ = false)
      'Match Play'
    end

    def calculate_scores
      new_scores = []

      user1 = user
      user2 = opponent

      self.unplayed_holes = scoring_rule.course_holes.count
      self.running_score = 0
      self.opponent_running_score = 0
      self.holes_won = 0

      user1_handicap_allowance = scoring_rule.handicap_computer.match_play_handicap_allowance(user: user1)
      user2_handicap_allowance = scoring_rule.handicap_computer.match_play_handicap_allowance(user: user2)

      Rails.logger.debug { "MatchPlayScorecard Handicaps: #{user1.complete_name} (#{user1_handicap_allowance.pluck(:strokes).sum}) #{user1_handicap_allowance.pluck(:strokes)} / #{user2.complete_name} #{user2_handicap_allowance.pluck(:strokes).sum} #{user2_handicap_allowance.pluck(:strokes)}" }

      scoring_rule.course_holes.each_with_index do |hole, i|
        score = DerivedScorecardScore.new

        running_score_holes = scoring_rule.course_holes.limit(i + 1)
        score.strokes = score_for_holes(user1, user1_handicap_allowance, user2, user2_handicap_allowance, hole, running_score_holes)

        score.course_hole = hole
        new_scores << score
      end

      self.scores = new_scores
    end

    def score_for_holes(user1, user1_handicap_allowance, user2, user2_handicap_allowance, current_hole, holes)
      return 0 if user1.blank? || user2.blank?

      scorecard1 = tournament_day.primary_scorecard_for_user(user1)
      scorecard2 = tournament_day.primary_scorecard_for_user(user2)

      # verify the hole has been played
      current_hole_strokes1 = 0
      scorecard1.scores.each do |score|
        current_hole_strokes1 = score.strokes if score.course_hole == current_hole
      end

      current_hole_strokes2 = 0
      scorecard2.scores.each do |score|
        current_hole_strokes2 = score.strokes if score.course_hole == current_hole
      end

      return 0 if current_hole_strokes1.zero? || current_hole_strokes2.zero? # hole has not been played

      # if we get this far, we have stuff to calc
      self.unplayed_holes -= 1
      self.running_score = 0
      self.opponent_running_score = 0
      self.holes_won = 0

      holes.each do |hole|
        user1_score = scorecard1.scores.find_by(course_hole: hole)
        user2_score = scorecard2.scores.find_by(course_hole: hole)

        user1_hole_score = adjusted_strokes(user1_score.strokes, user1_handicap_allowance, hole)
        user2_hole_score = adjusted_strokes(user2_score.strokes, user2_handicap_allowance, hole)

        next if user1_score.blank? || user2_score.blank?

        Rails.logger.debug { "#{user.complete_name} and #{opponent.complete_name}. Hole #{hole.hole_number}: User 1: #{user1_hole_score} User 2: #{user2_hole_score}" }

        new_running_score = running_score
        new_opponent_running_score = opponent_running_score

        if user1_hole_score < user2_hole_score # user 1 won this hole
          new_running_score = running_score + 1
          new_opponent_running_score = opponent_running_score - 1

          self.holes_won += 1
        elsif user1_hole_score > user2_hole_score # user 1 lost this hole
          new_running_score = running_score - 1
          new_opponent_running_score = opponent_running_score + 1
        end

        self.running_score = new_running_score
        self.opponent_running_score = new_opponent_running_score
      end

      running_score
    end

    def match_has_ended?
      player_score_delta = (running_score - opponent_running_score).abs
      player_score_delta > unplayed_holes || unplayed_holes.zero?
    end

    def scorecard_result
      return MatchPlayScorecardResult::TIED if running_score == opponent_running_score
      return MatchPlayScorecardResult::INCOMPLETE unless match_has_ended?

      if running_score > opponent_running_score
        MatchPlayScorecardResult::WON
      else
        MatchPlayScorecardResult::LOST
      end
    end

    def extra_scoring_column_data
      result = scorecard_result

      if result == MatchPlayScorecardResult::TIED
        return 'All Square'
      elsif result == MatchPlayScorecardResult::LOST
        return 'L'
      elsif result == MatchPlayScorecardResult::WON
        return 'W'
      else
        in_progress_description = "#{running_score}&#{unplayed_holes}"

        if unplayed_holes != scoring_rule.course_holes.count && running_score > opponent_running_score
          return "W (#{in_progress_description})"
        else
          return in_progress_description
        end
      end
    end
  end
end
