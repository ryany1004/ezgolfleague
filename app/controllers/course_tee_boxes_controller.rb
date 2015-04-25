class CourseTeeBoxesController < BaseController
  before_action :fetch_course
  before_action :fetch_course_tee_box, :except => [:index, :new, :create]

  def index
    @course_tee_boxes = @course.course_tee_boxes
  end
  
  def new
    @course_tee_box = CourseTeeBox.new
  end
  
  def create
    @course_tee_box = CourseTeeBox.new(course_tee_box_params)
    @course_tee_box.course = @course

    if @course_tee_box.save
      redirect_to course_course_holes_path(@course), :flash => { :success => "The tee box was successfully created. Please add the hole information next." }
    else
      render :new
    end
  end
  
  def edit
  end
  
  def update
    if @course_tee_box.update(course_tee_box_params)
      redirect_to course_course_tee_boxes_path(@course), :flash => { :success => "The course tee box was successfully updated." }
    else      
      render :edit
    end
  end
  
  def destroy
    @course_tee_box.destroy
    
    redirect_to course_course_tee_boxes_path(@course), :flash => { :success => "The course tee box was successfully deleted." }
  end
  
  private
  
  def course_tee_box_params
    params.require(:course_tee_box).permit(:name, :rating, :slope)
  end
  
  def fetch_course
    @course = Course.find(params[:course_id])
  end

  def fetch_course_tee_box
    @course_tee_box = CourseTeeBox.find(params[:id])
  end

end
