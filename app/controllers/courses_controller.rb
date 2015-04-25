class CoursesController < BaseController
  before_action :fetch_course, :only => [:edit, :update, :destroy]
  before_action :initialize_form, :only => [:new, :edit]
  
  def index    
    @courses = Course.page params[:page]
    
    @page_title = "Courses"
  end
  
  def new
    @course = Course.new
  end
  
  def create
    @course = Course.new(course_params)

    if @course.save
      redirect_to course_course_tee_boxes_path(@course), :flash => { :success => "The course was successfully created. Please add tee box information next." }
    else
      initialize_form

      render :new
    end
  end

  def edit
  end
  
  def update
    if @course.update(course_params)
      redirect_to courses_path, :flash => { :success => "The course was successfully updated." }
    else
      initialize_form
      
      render :edit
    end
  end
  
  def destroy
    @course.destroy
    
    redirect_to courses_path, :flash => { :success => "The course was successfully deleted." }
  end
  
  private
  
  def course_params
    params.require(:course).permit(:name, :street_address_1, :street_address_2, :city, :us_state, :postal_code, :phone_number)
  end
  
  def fetch_course
    @course = Course.find(params[:id])
  end
  
  def initialize_form    
    @us_states = US_STATES
  end
  
end
