module GameTypes
  class IndividualStrokePlay < GameTypes::GameTypeBase
    include Rails.application.routes.url_helpers

    def display_name
      return "Individual Stroke Play"
    end

    def game_type_id
      return 1
    end

    def other_group_members(user)
      other_members = []

      group = self.tournament_day.tournament_group_for_player(user)
      group.golf_outings.each do |outing|
        other_members << outing.user if outing.user != user
      end

      return other_members
    end

    def user_is_in_group?(user, tournament_group)
      tournament_group.golf_outings.each do |outing|
        return true if user == outing.user
      end

      return false
    end

    ##Setup

    def setup_partial
      return "shared/game_type_setup/individual_stroke_play"
    end

    def use_back_nine_key
      return "ShouldUseBackNineForTies-T-#{self.tournament_day.id}-GT-#{self.game_type_id}"
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
        return true
      else
        return false
      end
    end

    def can_be_played?
      return true if self.tournament_day.data_was_imported == true

      return false if self.tournament_day.tournament_groups.count == 0
      return false if self.tournament_day.flights.count == 0
      return false if self.tournament_day.course_holes.count == 0

      return true
    end

    ##Ranking

    def sort_rank_players_in_flight!(flight_players)
      if self.use_back_9_to_break_ties?
        Rails.logger.info { "Tie-breaking is enabled" }

        if self.tournament_day.course_holes.count == 9 #if a 9-hole tournament, compare score by score
          Rails.logger.info { "9-Hole Tie-Breaking" }

          par_related_net_scores = flight_players.map{|x| x[:par_related_net_score]}

          if par_related_net_scores.uniq.length != par_related_net_scores.length
            Rails.logger.info { "We have tied players, using raw_scores" }

            flight_players.sort_by! {|x| [x[:par_related_net_score], x[:raw_scores]]}
          else
            Rails.logger.info { "No tied players..." }

            flight_players.sort_by! {|x| [x[:par_related_net_score], x[:back_nine_net_score]]}
          end
        else
          Rails.logger.info { "18-Hole Tie-Breaking" }

          flight_players.sort_by! {|x| [x[:par_related_net_score], x[:back_nine_net_score]]}
        end
      else
        Rails.logger.info { "Tie-breaking is disabled" }

        flight_players.sort! { |x,y| x[:par_related_net_score] <=> y[:par_related_net_score] } #NOTE: Not DRY but there's some sort of binding error with just calling super. :-(
      end
    end

    ##Scoring

    def related_scorecards_for_user(user, only_human_scorecards = false)
      other_scorecards = []

      self.tournament_day.other_group_members(user).each do |player|
        other_scorecards << self.tournament_day.primary_scorecard_for_user(player)
      end

      return other_scorecards
    end

  end
end
