json.cache! ['v1', tournament] do
	json.name 												tournament.name
	json.server_id										tournament.server_id
	json.is_finalized									tournament.is_finalized
	json.number_of_players						tournament.number_of_players
	json.is_open_for_registration? 		tournament.is_open_for_registration?
	json.dues_amount									tournament.mandatory_dues_amount
	json.allow_credit_card_payment 		tournament.allow_credit_card_payment

	json.league do
		json.name 										tournament.league.name
		json.server_id								tournament.league.server_id
		json.apple_pay_merchant_id		tournament.league.apple_pay_merchant_id
		json.supports_apple_pay				tournament.league.supports_apple_pay
		json.stripe_publishable_key		tournament.league.stripe_publishable_key
	end

	json.tournament_days tournament.tournament_days do |day|
		json.server_id										day.server_id
		json.tournament_at								day.tournament_at
		json.game_type_id									day.legacy_game_type_id
		json.can_be_played?								day.can_be_played?
		json.registered_user_ids					day.registered_user_ids
		json.paid_user_ids								day.paid_user_ids
		json.superuser_user_ids						day.superuser_user_ids
		json.league_admin_user_ids				day.league_admin_user_ids
		json.show_teams?									day.needs_daily_teams?
		json.enter_scores_until_finalized	day.enter_scores_until_finalized

		json.paid_contests day.optional_scoring_rules do |contest|
			json.server_id							contest.server_id
			json.name										contest.name
			json.dues_amount						contest.dues_amount
		end

		json.course do
			json.server_id						day.course.server_id
			json.name									day.course.name
			json.street_address_1			day.course.street_address_1
			json.city									day.course.city
			json.us_state							day.course.us_state
			json.postal_code					day.course.postal_code
			json.latitude							day.course.latitude
			json.longitude						day.course.longitude
		end
	end
end