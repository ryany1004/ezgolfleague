json.cache! ['v1', tournament_result] do
  json.payouts tournament_result[:payouts], partial: 'payout', as: :payout
  json.rankings tournament_result[:rankings], partial: 'ranking', as: :ranking
  json.contests tournament_result[:contests], partial: 'contest', as: :contest
end
