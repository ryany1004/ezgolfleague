json.day_flights do
	json.partial! 'flight', collection: @day_flights, as: :flight
end
json.combined_flights do
	json.partial! 'flight', collection: @combined_flights, as: :flight
end