class Api::V2::CourseTeeBoxesController < BaseController
  def index
    @course = Course.find(params[:course_id])

    render json: @course.course_tee_boxes.to_json
  end
end
