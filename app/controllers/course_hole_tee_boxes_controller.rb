class CourseHoleTeeBoxesController < ApplicationController
  before_action :authenticate_user!
  before_action :fetch_course
  before_action :fetch_course_hole
  before_action :fetch_tee_box
  
  def destroy
    @course_hole_tee_box.destroy
    
    redirect_to edit_course_course_hole_path(@course, @course_hole), :flash => { :success => "The tee box was successfully deleted." }
  end
  
  private
  
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
