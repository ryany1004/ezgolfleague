class UpdateToBigint < ActiveRecord::Migration[5.1]
  def change
		change_column :contest_holes, :id, :bigint
		change_column :contest_holes, :course_hole_id, :bigint
		
		change_column :contest_results, :id, :bigint
		change_column :contest_results, :contest_id, :bigint
		change_column :contest_results, :contest_hole_id, :bigint
		change_column :contest_results, :winner_id, :bigint

		change_column :contests, :id, :bigint
		change_column :contests, :tournament_day_id, :bigint
		change_column :contests, :overall_winner_contest_result_id, :bigint

		change_column :contests_users, :contest_id, :bigint
		change_column :contests_users, :user_id, :bigint
		
		change_column :course_hole_tee_boxes, :id, :bigint
		change_column :course_hole_tee_boxes, :course_hole_id, :bigint
		change_column :course_hole_tee_boxes, :course_tee_box_id, :bigint

		change_column :course_holes, :id, :bigint
		
		change_column :course_holes_tournament_days, :course_hole_id, :bigint
		change_column :course_holes_tournament_days, :tournament_day_id, :bigint

		change_column :course_tee_boxes, :id, :bigint
		change_column :course_tee_boxes, :course_id, :bigint

		change_column :courses, :id, :bigint

		change_column :daily_teams, :id, :bigint
		change_column :daily_teams, :tournament_group_id, :bigint
		change_column :daily_teams, :parent_team_id, :bigint

		change_column :daily_teams_users, :daily_team_id, :bigint
		change_column :daily_teams_users, :user_id, :bigint

		change_column :flights, :id, :bigint
		change_column :flights, :course_tee_box_id, :bigint
		change_column :flights, :tournament_day_id, :bigint
		change_column :flights, :league_season_scoring_group_id, :bigint

		change_column :flights_users, :flight_id, :bigint
		change_column :flights_users, :user_id, :bigint

		change_column :game_type_metadata, :id, :bigint
		change_column :game_type_metadata, :course_hole_id, :bigint
		change_column :game_type_metadata, :scorecard_id, :bigint
		change_column :game_type_metadata, :daily_team_id, :bigint

		change_column :golf_outings, :id, :bigint
		change_column :golf_outings, :user_id, :bigint
		change_column :golf_outings, :course_tee_box_id, :bigint
		change_column :golf_outings, :tournament_group_id, :bigint

		change_column :league_memberships, :id, :bigint
		change_column :league_memberships, :league_id, :bigint
		change_column :league_memberships, :user_id, :bigint

		change_column :league_season_ranking_groups, :id, :bigint
		change_column :league_season_ranking_groups, :league_season_id, :bigint

		change_column :league_season_rankings, :id, :bigint
		change_column :league_season_rankings, :league_season_ranking_group_id, :bigint
		change_column :league_season_rankings, :user_id, :bigint

		change_column :league_season_scoring_groups, :id, :bigint
		change_column :league_season_scoring_groups, :league_season_id, :bigint

		change_column :league_season_scoring_groups_users, :league_season_scoring_group_id, :bigint
		change_column :league_season_scoring_groups_users, :user_id, :bigint

		change_column :league_seasons, :id, :bigint
		change_column :league_seasons, :league_id, :bigint

		change_column :leagues, :id, :bigint

		change_column :mobile_devices, :id, :bigint
		change_column :mobile_devices, :user_id, :bigint

		change_column :notification_templates, :id, :bigint
		change_column :notification_templates, :tournament_id, :bigint
		change_column :notification_templates, :league_id, :bigint

		change_column :notifications, :id, :bigint
		change_column :notifications, :notification_template_id, :bigint
		change_column :notifications, :user_id, :bigint

		change_column :payments, :id, :bigint
		change_column :payments, :user_id, :bigint
		change_column :payments, :tournament_id, :bigint
		change_column :payments, :contest_id, :bigint
		change_column :payments, :league_season_id, :bigint
		change_column :payments, :payment_id, :bigint

		change_column :payout_results, :id, :bigint
		change_column :payout_results, :user_id, :bigint
		change_column :payout_results, :payout_id, :bigint
		change_column :payout_results, :flight_id, :bigint

		change_column :payouts, :id, :bigint
		change_column :payouts, :flight_id, :bigint

		change_column :scorecards, :id, :bigint
		change_column :scorecards, :golf_outing_id, :bigint
		change_column :scorecards, :designated_editor_id, :bigint

		change_column :scores, :id, :bigint
		change_column :scores, :scorecard_id, :bigint
		change_column :scores, :course_hole_id, :bigint

		change_column :scoring_rules_users, :scoring_rule_id, :bigint
		change_column :scoring_rules_users, :user_id, :bigint

		change_column :subscription_credits, :id, :bigint
		change_column :subscription_credits, :league_season_id, :bigint

		change_column :tournament_day_results, :id, :bigint
		change_column :tournament_day_results, :user_id, :bigint
		change_column :tournament_day_results, :user_primary_scorecard_id, :bigint
		change_column :tournament_day_results, :flight_id, :bigint

		change_column :tournament_days, :id, :bigint
		change_column :tournament_days, :tournament_id, :bigint
		change_column :tournament_days, :course_id, :bigint

		change_column :tournament_groups, :id, :bigint
		change_column :tournament_groups, :tournament_day_id, :bigint

		change_column :tournaments, :id, :bigint
		change_column :tournaments, :league_id, :bigint

		change_column :users, :id, :bigint
		change_column :users, :parent_id, :bigint

		drop_table :delayed_jobs
  end
end
