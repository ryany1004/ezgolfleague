json.cache! ['v1', payout] do
	json.flight_number 			payout[:flight_number]
	json.name								payout[:name]
	json.id									payout[:id]
	json.amount							payout[:amount]
	json.points							payout[:points]
end