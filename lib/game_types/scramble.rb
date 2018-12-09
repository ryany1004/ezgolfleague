require 'active_record'

module GameTypes
  class Scramble < GameTypes::IndividualStrokePlay
    # METADATA_KEY = "scramble_scorecard_for_best_ball_hole"

    # def display_name
    #   "Scramble"
    # end

    # def game_type_id
    #   6
    # end

    # def show_other_scorecards?
    #   true
    # end

    ##Teams

    # def allow_teams
    #   GameTypes::TEAMS_REQUIRED
    # end

    # def show_teams?
    #   true
    # end

    # def number_of_players_per_team
    #   GameTypes::VARIABLE
    # end

    # def players_create_teams?
    #   false
    # end

    ##Setup

    # def setup_partial
    #   "shared/game_type_setup/scramble"
    # end

    # def scorecard_score_cell_partial
    #   "shared/game_types/scramble_popup"
    # end

    # def scorecard_post_embed_partial
    #   "shared/game_types/scramble_post_embed"
    # end

    # def handicap_percentage_key
    #   "HandicapPercentageKey-T-#{self.tournament_day.id}-GT-#{self.game_type_id}"
    # end

    # def use_back_nine_key
    #   "ShouldUseBackNineForTies-T-#{self.tournament_day.id}-GT-#{self.game_type_id}"
    # end

    # def save_setup_details(game_type_options)
    #   handicap_percentage = 0
    #   handicap_percentage = game_type_options["handicap_percentage"]

    #   metadata = GameTypeMetadatum.find_or_create_by(search_key: handicap_percentage_key)
    #   metadata.float_value = handicap_percentage
    #   metadata.save

    #   should_use_back_nine_for_ties = 0
    #   should_use_back_nine_for_ties = 1 if game_type_options["use_back_9_to_handle_ties"] == 'true'

    #   metadata = GameTypeMetadatum.find_or_create_by(search_key: use_back_nine_key)
    #   metadata.integer_value = should_use_back_nine_for_ties
    #   metadata.save
    # end

    # def remove_game_type_options
    #   metadata = GameTypeMetadatum.where(search_key: handicap_percentage_key).first
    #   metadata.destroy unless metadata.blank?

    #   metadata = GameTypeMetadatum.where(search_key: use_back_nine_key).first
    #   metadata.destroy unless metadata.blank?
    # end

    # def current_handicap_percentage
    #   metadata = GameTypeMetadatum.where(search_key: handicap_percentage_key).first

    #   if metadata.blank?
    #     "0.0"
    #   else
    #     metadata.float_value
    #   end
    # end

    # def use_back_9_to_break_ties?
    #   metadata = GameTypeMetadatum.where(search_key: use_back_nine_key).first

    #   if !metadata.blank? && metadata.integer_value == 1
    #     true
    #   else
    #     false
    #   end
    # end

    ##Metadata

    # def update_metadata(metadata)
    #   scorecard = Scorecard.find(metadata[:scorecard_id])
    #   tournament_day = scorecard.tournament_day
    #   team = tournament_day.golfer_team_for_player(scorecard.golf_outing.user)
    #   course_hole = CourseHole.find(metadata[:course_hole_id])

    #   metadata = GameTypeMetadatum.find_or_create_by(golfer_team: team, course_hole: course_hole, search_key: METADATA_KEY)
    #   metadata.scorecard = scorecard
    #   metadata.save
    # end

    # def selected_scorecard_for_score(score) #this is the one selected as the tee shot
    #   return nil if score.scorecard.golf_outing.blank?

    #   tournament_day = score.scorecard.tournament_day
    #   team = tournament_day.golfer_team_for_player(score.scorecard.golf_outing.user)
    #   metadata = GameTypeMetadatum.where(golfer_team: team, course_hole: score.course_hole, search_key: METADATA_KEY).first

    #   metadata&.scorecard
    # end

    ##Scoring

    # def assign_payouts_from_scores
    #   super

    #   Rails.logger.info { "Assigning Team Scores" }

    #   self.tournament_day.reload

    #   self.tournament_day.payout_results.each do |result|
    #     team = self.tournament_day.golfer_team_for_player(result.user)

    #     unless team.blank?
    #       team.users.where("id != ?", result.user.id).each do |teammate|
    #         Rails.logger.info { "Scramble Teams: Assigning #{teammate.complete_name} to Payout #{result.id}" }

    #         PayoutResult.create(payout: result.payout, user: teammate, flight: result.flight, tournament_day: self.tournament_day, amount: result.amount, points: result.points)
    #       end
    #     end
    #   end
    # end

    # def other_group_members(user)
    #   other_members = []

    #   team = self.tournament_day.golfer_team_for_player(user)
    #   team&.users&.each do |u|
    #     other_members << u if u != user
    #   end

    #   other_members
    # end

    # def related_scorecards_for_user(user, only_human_scorecards = false)
    #   []
    # end

    # def override_scorecard_name_for_scorecard(scorecard)
    #   player_names = scorecard.golf_outing.user.last_name + "/"

    #   other_members = self.tournament_day.other_group_members(scorecard.golf_outing.user)
    #   other_members.each do |player|
    #     player_names << player.last_name

    #     player_names << "/" if player != other_members.last
    #   end

    #   "#{player_names} Scramble"
    # end

    # def individual_team_scorecards_for_scorecard(scorecard)
    #   scorecards = [scorecard]

    #   other_members = self.tournament_day.other_group_members(scorecard.golf_outing.user)
    #   other_members.each do |player|
    #     other_scorecard = self.tournament_day.primary_scorecard_for_user(player)

    #     scorecards << other_scorecard
    #   end

    #   scorecards
    # end

    # def after_updating_scores_for_scorecard(scorecard)
    #   Scorecard.transaction do
    #     self.tournament_day.other_group_members(scorecard.golf_outing.user).each do |player|
    #       other_scorecard = self.tournament_day.primary_scorecard_for_user(player)

    #       Rails.logger.info { "Copying Score Data From #{scorecard.golf_outing.user.complete_name} to #{player.complete_name}" }

    #       scorecard.scores.each do |score|
    #         other_score = other_scorecard.scores.where(course_hole: score.course_hole).first
    #         other_score.strokes = score.strokes
    #         other_score.save
    #       end

    #       #make sure the results get updated also
    #       self.tournament_day.tournament_day_results.where(user: player).destroy_all
    #     end
    #   end
    # end

    # def course_handicap_for_game_type(golf_outing)
    #   team_adjusted_course_handicap = 0.0

    #   team_adjusted_course_handicap += super(golf_outing)

    #   self.other_group_members(golf_outing.user).each do |u|
    #     user_golf_outing = self.tournament_day.golf_outing_for_player(u)

    #     unless user_golf_outing.blank?
    #       team_adjusted_course_handicap += super(user_golf_outing)
    #     end
    #   end

    #   #apply percentage
    #   percentage = self.current_handicap_percentage.to_f
    #   if percentage > 0.0
    #     percentage = percentage / 100.0
    #   else
    #     percentage = 1.0
    #   end

    #   Rails.logger.info { "Scramble: Adjusting team handicap from #{team_adjusted_course_handicap} with percentage: #{percentage}" }

    #   team_adjusted_course_handicap = (team_adjusted_course_handicap * percentage)

    #   Rails.logger.info { "Scramble team handicap: #{team_adjusted_course_handicap}" }

    #   team_adjusted_course_handicap
    # end

  end
end
