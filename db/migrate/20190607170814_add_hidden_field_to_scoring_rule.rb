class AddHiddenFieldToScoringRule < ActiveRecord::Migration[5.2]
  def change
    add_column :scoring_rules, :base_stroke_play, :boolean, default: false

    ScoringRule.update_all(base_stroke_play: false)
  end
end
