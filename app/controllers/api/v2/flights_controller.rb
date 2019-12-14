class Api::V2::FlightsController < BaseController
  respond_to :json

  before_action :fetch

  def create
    payload = ActiveSupport::JSON.decode(request.body.read)

    @errors = []

    flight = Flight.new(tournament_day: @tournament_day,
                        flight_number: payload['flightNumber'],
                        lower_bound: payload['lowerBound'],
                        upper_bound: payload['upperBound'],
                        course_tee_box: course_tee_box(payload['courseTeeBox']['id']))
    @errors << flight.errors

    if flight.save
      render json: flight
    else
      render json: { errors: @errors }
    end
  end

  def update
    payload = ActiveSupport::JSON.decode(request.body.read)

    @errors = []

    flight.update(flight_number: payload['flightNumber'],
                  lower_bound: payload['lowerBound'],
                  upper_bound: payload['upperBound'],
                  course_tee_box: course_tee_box(payload['courseTeeBox']['id']))
    @errors << flight.errors

    render json: { errors: @errors }
  end

  def destroy
    flight.destroy

    render json: :ok
  end

  private

  def course_tee_box(course_tee_box_id)
    @tournament_day.course.course_tee_boxes.find(course_tee_box_id)
  end

  def flight
    @tournament_day.flights.find(params[:id])
  end

  def fetch
    @tournament = fetch_tournament_from_user_for_tournament_id(params[:tournament_id])
    @tournament_day = @tournament.tournament_days.find(params[:tournament_day_id])
  end
end
