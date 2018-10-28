module GameTypes
  class IndividualStrokePlay < GameTypes::GameTypeBase
    include Rails.application.routes.url_helpers

    def display_name
      "Individual Stroke Play"
    end

    def game_type_id
      1
    end

    def other_group_members(user)
      other_members = []

      group = self.tournament_day.tournament_group_for_player(user)
      group.golf_outings.each do |outing|
        other_members << outing.user if outing.user != user
      end

      other_members
    end

    def user_is_in_group?(user, tournament_group)
      tournament_group.golf_outings.each do |outing|
        return true if user == outing.user
      end

      false
    end

    ##Setup

    def setup_partial
      "shared/game_type_setup/individual_stroke_play"
    end

    def use_back_nine_key
      "ShouldUseBackNineForTies-T-#{self.tournament_day.id}-GT-#{self.game_type_id}"
    end

    def save_setup_details(game_type_options)
      should_use_back_nine_for_ties = 0
      should_use_back_nine_for_ties = 1 if game_type_options["use_back_9_to_handle_ties"] == 'true'

      metadata = GameTypeMetadatum.find_or_create_by(search_key: use_back_nine_key)
      metadata.integer_value = should_use_back_nine_for_ties
      metadata.save
    end

    def remove_game_type_options
      metadata = GameTypeMetadatum.where(search_key: use_back_nine_key).first
      metadata.destroy unless metadata.blank?
    end

    def use_back_9_to_break_ties?
      metadata = GameTypeMetadatum.where(search_key: use_back_nine_key).first

      if !metadata.blank? && metadata.integer_value == 1
        true
      else
        false
      end
    end

    def can_be_played?
      return true if self.tournament_day.data_was_imported == true

      return false if self.tournament_day.tournament_groups.count == 0
      return false if self.tournament_day.flights.count == 0
      return false if self.tournament_day.course_holes.count == 0

      true
    end

    ##Scoring

    def related_scorecards_for_user(user, only_human_scorecards = false)
      other_scorecards = []

      self.tournament_day.other_group_members(user).each do |player|
        other_scorecards << self.tournament_day.primary_scorecard_for_user(player)
      end

      other_scorecards
    end

  end
end
