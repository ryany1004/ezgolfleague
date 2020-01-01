class Api::V2::CoursesController < BaseController
  respond_to :json

  def index
    @courses = Course.all.order(:name).limit(100)
    return if params[:search].blank?

    search_string = "%#{params[:search].downcase}%"
    @courses = @courses
               .where('lower(name) LIKE ? OR lower(city) LIKE ? OR lower(us_state) LIKE ?', search_string, search_string, search_string)
               .includes(:course_holes, :course_tee_boxes)

    render json: @courses.to_json(methods: :number_of_holes)
  end

  def show
    @course = Course.find(params[:id])

    render json: @course.to_json
  end
end
