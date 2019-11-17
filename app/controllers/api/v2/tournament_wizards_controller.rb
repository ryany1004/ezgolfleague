class Api::V2::TournamentWizardsController < BaseController
  def create
    details = ActiveSupport::JSON.decode(request.body.read)

    render json: details.to_json
  end
end
