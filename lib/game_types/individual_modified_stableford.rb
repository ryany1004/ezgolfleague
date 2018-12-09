module GameTypes
  class IndividualModifiedStableford < GameTypes::IndividualStrokePlay

    # def display_name
    #   return "Individual Modified Stableford"
    # end

    # def game_type_id
    #   return 3
    # end

    # def show_other_scorecards?
    #   true
    # end

    ##Setup

    # def setup_partial
    #   return "shared/game_type_setup/individual_stableford"
    # end

    # def leaderboard_partial_name
    #   'stableford_leaderboard'
    # end

    # def score_key(prefix)
    #   return "StablefordScore-#{self.tournament_day.id}-GT-#{self.game_type_id}-#{prefix}"
    # end

    # def metadata_score(prefix)
    #   metadata = GameTypeMetadatum.where(search_key: self.score_key(prefix)).first

    #   if !metadata.blank? && !metadata.integer_value.blank?
    #     metadata.integer_value
    #   else
    #     nil
    #   end
    # end

    # def double_eagle_score
    #   metadata_score = self.metadata_score("double_eagle_score")

    #   unless metadata_score.blank?
    #     metadata_score
    #   else
    #     return 16
    #   end
    # end

    # def eagle_score
    #   metadata_score = self.metadata_score("eagle_score")

    #   unless metadata_score.blank?
    #     metadata_score
    #   else
    #     return 8
    #   end
    # end

    # def birdie_score
    #   metadata_score = self.metadata_score("birdie_score")

    #   unless metadata_score.blank?
    #     metadata_score
    #   else
    #     return 4
    #   end
    # end

    # def par_score
    #   metadata_score = self.metadata_score("par_score")

    #   unless metadata_score.blank?
    #     metadata_score
    #   else
    #     return 2
    #   end
    # end

    # def bogey_score
    #   metadata_score = self.metadata_score("bogey_score")

    #   unless metadata_score.blank?
    #     metadata_score
    #   else
    #     return 1
    #   end
    # end

    # def double_bogey_score
    #   metadata_score = self.metadata_score("double_bogey_score")

    #   unless metadata_score.blank?
    #     metadata_score
    #   else
    #     return 0
    #   end
    # end

    # def save_setup_details(game_type_options)
    #   score_types = ["double_eagle_score", "eagle_score", "birdie_score", "par_score", "bogey_score", "double_bogey_score"]
    #   score_types.each do |score_type|
    #     score = 0
    #     score = game_type_options[score_type]

    #     metadata = GameTypeMetadatum.find_or_create_by(search_key: self.score_key(score_type))
    #     metadata.integer_value = score
    #     metadata.save
    #   end
    # end

    # def remove_game_type_options
    #   score_types = ["double_eagle_score", "eagle_score", "birdie_score", "par_score", "bogey_score", "double_bogey_score"]
    #   score_types.each do |score_type|
    #     metadata = GameTypeMetadatum.where(search_key: self.score_key(score_type)).first
    #     metadata.destroy unless metadata.blank?
    #   end
    # end

    ## Scoring

    # def compute_player_score(user, use_handicap = true, holes = [])
    #   if !self.tournament.includes_player?(user)
    #     Rails.logger.info { "Tournament Does Not Include Player: #{user.complete_name}" }

    #     return nil
    #   end

    #   total_score = 0

    #   scorecard = self.stableford_scorecard_for_user(user)
    #   return 0 if scorecard.blank? || scorecard.scores.blank?

    #   Rails.logger.debug { "Stableford Computing for User: #{user.complete_name} holes: #{holes}" }

    #   scorecard.scores.each do |score|
    #     should_include_score = true #allows us to calculate partial scores, i.e. back 9
    #     if holes.blank? == false
    #       should_include_score = false if !holes.include? score.course_hole.hole_number
    #     end

    #     if should_include_score == true
    #       hole_score = score.strokes

    #       total_score = total_score + hole_score
    #     end
    #   end

    #   total_score = 0 if total_score < 0

    #   Rails.logger.debug { "Stableford Computed: #{total_score}. User: #{user.complete_name} holes: #{holes}" }

    #   return total_score
    # end

    # def related_scorecards_for_user(user, only_human_scorecards = false)
    #   other_scorecards = []

    #   other_scorecards << self.stableford_scorecard_for_user(user) if only_human_scorecards == false

    #   self.tournament_day.other_group_members(user).each do |player|
    #     other_scorecards << self.tournament_day.primary_scorecard_for_user(player)
    #     other_scorecards << self.stableford_scorecard_for_user(player) if only_human_scorecards == false
    #   end

    #   return other_scorecards
    # end

    # def stableford_scorecard_for_user(user)
    #   scorecard = IndividualStablefordScorecard.new
    #   scorecard.user = user
    #   scorecard.underlying_tournament_day = self.tournament_day
    #   scorecard.calculate_scores

    #   return scorecard
    # end
  end
end
