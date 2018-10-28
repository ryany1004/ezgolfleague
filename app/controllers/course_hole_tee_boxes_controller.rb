class CourseHoleTeeBoxesController < BaseController
  before_action :fetch_course
  before_action :fetch_course_hole
  before_action :fetch_tee_box, except: [:new, :create]
  
  def new
    @course_hole_tee_box = CourseHoleTeeBox.new
  end
  
  def create
    @course_hole_tee_box = CourseHoleTeeBox.new(course_hole_tee_box_params)
    @course_hole_tee_box.course_hole = @course_hole
    
    if @course_hole_tee_box.save      
      redirect_to course_course_holes_path(@course), flash: { success: "The tee box was successfully created." }
    else            
      render :new
    end
  end
  
  def destroy
    @course_hole_tee_box.destroy
    
    redirect_to course_course_holes_path(@course), flash: { success: "The tee box was successfully deleted." }
  end
  
  private
  
  def course_hole_tee_box_params
    params.require(:course_hole_tee_box).permit(:name, :yardage, :description, :course_tee_box_id)
  end
  
  def fetch_course
    @course = Course.find(params[:course_id])
  end
  
  def fetch_course_hole
    @course_hole = CourseHole.find(params[:course_hole_id])
  end
  
  def fetch_tee_box
    @course_hole_tee_box = CourseHoleTeeBox.find(params[:id])
  end
  
end
