module Updaters
  class TournamentGroupUpdater

    def update_for_params(tournament_group, params)
      player_info = params[:player_submit][:member_id]
      players_signed_up = self.player_signup(tournament_group, player_info) if player_info.present?

      if players_signed_up.present?
        team_info = params[:player_submit][:daily_team_ids]
        self.team_signup(tournament_group, team_info) if team_info.present?

        scoring_rule_info = params[:player_submit][:optional_scoring_rule_signups]
        self.optional_scoring_rule_signup(tournament_group, scoring_rule_info) if scoring_rule_info.present?
      end

      players_signed_up
    end

    def player_signup(tournament_group, player_info)
      players_signed_up = []

      player_info.keys.each do |slot_id|
        user = User.where(id: player_info[slot_id]).first

        unless user.blank?
          tournament_group.add_or_move_user_to_group(user)
          players_signed_up << user
        end
      end

      players_signed_up
    end

    def team_signup(tournament_group, team_info)
      team_info.keys.each do |slot_id|
        golf_outing = tournament_group.golf_outings[slot_id.to_i]

        unless golf_outing.blank?
          user = golf_outing.user
          team = DailyTeam.find(team_info[slot_id])

          unless user.blank? || team.blank?
            existing_team = tournament_group.tournament_day.daily_team_for_player(user)

            if team != existing_team
              existing_team.users.delete(user) unless existing_team.blank?

              team.users << user
            end
          end
        end
      end
    end

    def optional_scoring_rule_signup(tournament_group, rule_info)
      rule_info.keys.each do |slot_id|
        golf_outing = tournament_group.golf_outings[slot_id.to_i]

        user = golf_outing&.user
        if user.present?
          rules = rule_info[slot_id].reject(&:empty?)

          if rules.present?
            rules_should_be_enrolled = ScoringRule.where(id: rules)
            rules_enrolled = tournament_group.tournament_day.optional_scoring_rules_for_user(user: user)

            rules_to_add = rules_should_be_enrolled - rules_enrolled
            rules_to_add.each do |r|
              r.users << user
            end

            rules_enrolled = tournament_group.tournament_day.optional_scoring_rules_for_user(user: user)
            rules_to_remove = tournament_group.tournament_day.tournament.optional_scoring_rules - rules_should_be_enrolled
            rules_to_remove.each do |r|
              r.users.destroy(user)
            end
          else # remove all
            tournament_group.tournament_day.tournament.optional_scoring_rules.each do |rule|
              rule.users.destroy(user)
            end
          end
        end
      end
    end
  end
end
