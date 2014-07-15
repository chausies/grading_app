class GradingsController < ApplicationController
  before_action :set_grading, except: :index
  before_action :signed_in_user
  before_action :set_enrollment, except: :index
  before_action :has_permission, except: :index

  def show
  end

  def update
    if @grading.update grading_params.merge(finished_grading: true)
      flash[:success] = 'Assigned grading.'
      redirect_to @grading
    else
      render :show
    end
  end

  def index
    @enr_hash = {}
    current_user.enrollments.reverse.each do |enrollment|
      @enr_hash[enrollment] ||= {}
      enrollment.given_gradings.reverse.each do |grading|
        @enr_hash[enrollment][grading.assignment] ||= []
        @enr_hash[enrollment][grading.assignment].append grading
      end
    end
  end

  private
    def set_grading
      @grading = Grading.find(params[:id])
      @assignment = Assignment.find @grading.assignment
      @course = @assignment.course
      @grader = Enrollment.find @grading.grader
      @gradee = Enrollment.find @grading.gradee
      @submission = @gradee.submissions.where(assignment_id: @assignment.id).first
    end

    def set_enrollment
      @enrollment = current_user.nil? ? false : current_user.enrollments.find_by(course_id: @course.id)
    end

    def has_permission
      unless !@enrollment.nil? and (@enrollment.id == @grader.id or @enrollment.status > Statuses::READER)
        redirect_to @course, notice: "You're not supposed to do this grading ಠ_ಠ"
      end
    end

    # Only allow a trusted parameter "white list" through.
    def grading_params
      params[:grading].permit(:score)
    end
end
