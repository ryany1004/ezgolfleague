class CourseHolesController < ApplicationController
  before_action :authenticate_user!
  before_action :fetch_course, :only => [:new, :edit, :create, :update, :destroy]
  before_action :fetch_course_hole, :only => [:edit, :update, :destroy]
  
  respond_to :html, :js
  
  def new
    @course_hole = CourseHole.new
    @course_hole.hole_number = @course.course_holes.last.hole_number + 1 if @course.course_holes.count > 0
  end

  def create
    @course_hole = CourseHole.new(course_hole_params)
    @course_hole.course = @course
    @course_hole.save
  end

  def edit
  end
  
  def update
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
    params.require(:course_hole).permit(:hole_number, :par)
  end
  
end
