namespace :calculate_handicaps do
  desc 'Process Automatic Handicap Calculations'
  task pending: :environment do
  	League.where(calculate_handicaps_from_past_rounds: true).each do |l|
  		HandicapCalculationJob.perform_later(l)
  	end
  end
end