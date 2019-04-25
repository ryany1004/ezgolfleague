class CoursesController < BaseController
  before_action :fetch_course, only: [:edit, :update, :destroy]
  before_action :initialize_form, only: [:new, :edit]

  def index
    @page_title = 'Courses'

    @courses = Course.order(:name).page params[:page]

    return if params[:search].blank?

    search_string = "%#{params[:search].downcase}%"
    @courses = @courses
               .where('lower(name) LIKE ? OR lower(city) LIKE ? OR lower(us_state) LIKE ?', search_string, search_string, search_string)
  end

  def list
    @courses = Course.all.order(:name).limit(100)

    return if params[:search].blank?

    search_string = "%#{params[:search].downcase}%"
    @courses = @courses
               .where('lower(name) LIKE ? OR lower(city) LIKE ? OR lower(us_state) LIKE ?', search_string, search_string, search_string)

    render json: @courses.to_json
  end

  def new
    @course = Course.new
  end

  def create
    @course = Course.new(course_params)
    @course.geocode

    if @course.save
      redirect_to course_course_tee_boxes_path(@course), flash:
      { success: 'The course was successfully created. Please add tee box information next.' }
    else
      initialize_form

      render :new
    end
  end

  def edit; end

  def update
    if @course.update(course_params)
      redirect_to courses_path, flash:
      { success: 'The course was successfully updated.' }
    else
      initialize_form

      render :edit
    end
  end

  def destroy
    @course.destroy

    redirect_to courses_path, flash:
    { success: 'The course was successfully deleted.' }
  end

  private

  def course_params
    params.require(:course).permit(:name,
                                   :street_address_1,
                                   :street_address_2,
                                   :city,
                                   :us_state,
                                   :postal_code,
                                   :country,
                                   :phone_number)
  end

  def fetch_course
    @course = Course.find(params[:id])
  end

  def initialize_form
    @us_states = GEO_STATES
    @countries = COUNTRIES
  end
end
