json.cache! ['v1', league] do
	json.name 									league.name
	json.league_description			league.league_description
	json.contact_name 					league.contact_name
	json.contact_phone 					league.contact_phone
	json.contact_email 					league.contact_email
	json.location 							league.location
	json.supports_apple_pay			league.supports_apple_pay
	json.apple_pay_merchant_id	league.apple_pay_merchant_id
	json.server_id							league.server_id
	json.stripe_publishable_key	league.stripe_publishable_key
	json.dues_amount						league.dues_amount
end