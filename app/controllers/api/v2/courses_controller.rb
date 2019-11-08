class Api::V2::CoursesController < BaseController
  def index
    @courses = Course.all.order(:name).limit(100)
    return if params[:search].blank?

    search_string = "%#{params[:search].downcase}%"
    @courses = @courses
               .where('lower(name) LIKE ? OR lower(city) LIKE ? OR lower(us_state) LIKE ?', search_string, search_string, search_string)

    render json: @courses.to_json
  end

  def show
    @course = Course.find(params[:id])

    render json: @course.to_json
  end
end
