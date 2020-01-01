class AddNetStrokesToScore < ActiveRecord::Migration[5.2]
  def change
  	add_column :scores, :net_strokes, :integer, default: 0

  	Scorecard.all.each do |scorecard|
  		scoring_rule = scorecard.golf_outing&.tournament_group&.tournament_day&.scorecard_base_scoring_rule

  		next if scoring_rule.blank?

  		handicap_computer = HandicapComputers::BaseHandicapComputer.new(scoring_rule)
			handicap_allowance = handicap_computer.handicap_allowance(user: scorecard.user)

			scorecard.scores.each do |score|
				score.net_strokes = score.strokes

				if handicap_allowance.present?
					handicap_allowance.each do |h|
						if h[:course_hole] == score.course_hole
							hole_net_score = score.strokes

							if h[:strokes] != 0
								hole_adjusted_score = score.strokes - h[:strokes]

	            	if hole_adjusted_score > 0
	            		hole_net_score = hole_adjusted_score
	            	end
							end

	          	score.net_strokes = hole_net_score
						end
					end
				end
			
				score.save
			end
  	end
  end
end
