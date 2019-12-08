class Api::V2::ScoringRulesController < BaseController
  respond_to :json

  def index
    @scoring_rules = ScoringRuleOption.scoring_rule_options(show_team_rules: false)

    render json: @scoring_rules.to_json
  end
end
