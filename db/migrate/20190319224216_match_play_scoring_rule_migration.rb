class MatchPlayScoringRuleMigration < ActiveRecord::Migration[5.2]
  def change
  	ScoringRule.where(type: "TeamMatchPlayScoringRule").update_all(type: "TeamMatchPlayVsScoringRule")
  end
end
