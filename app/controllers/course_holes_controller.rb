class CourseHolesController < ApplicationController
  before_action :authenticate_user!
  before_action :fetch_course, :only => [:index, :new, :edit, :create, :update, :destroy]
  before_action :fetch_course_hole, :only => [:edit, :update, :destroy]
  
  respond_to :html
  
  def index
    @course_holes = @course.course_holes
  end
  
  def new
    @course_hole = CourseHole.new
    @course_hole.hole_number = @course.course_holes.last.hole_number + 1 if @course.course_holes.count > 0
    @course_hole.course_hole_tee_boxes.build
  end

  def create
    @course_hole = CourseHole.new(course_hole_params)
    @course_hole.course = @course
    
    if @course_hole.save
      redirect_to course_course_holes_path(@course), :flash => { :success => "The hole was successfully created." }
    else
      render :new
    end
  end

  def edit
  end
  
  def update
    if @course_hole.update(course_hole_params)
      redirect_to edit_course_path(@course), :flash => { :success => "The hole was successfully updated." }
    else      
      render :edit
    end
  end
  
  def destroy
    @course_hole.destroy
    
    redirect_to edit_course_path(@course), :flash => { :success => "The course hole was successfully deleted." }
  end

  private
  
  def fetch_course
    @course = Course.find(params[:course_id])
  end
  
  def fetch_course_hole
    @course_hole = CourseHole.find(params[:id])
  end
  
  def course_hole_params
    params.require(:course_hole).permit(:hole_number, :par, :mens_handicap, :womens_handicap, course_hole_tee_boxes_attributes: [:course_tee_box_id, :description, :yardage])
  end
end
