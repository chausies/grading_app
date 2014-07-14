class GradingsController < ApplicationController
  before_action :set_grading, except: :index
  before_action :signed_in_user
  before_action :set_enrollment
  before_action :has_permission, except: :index

  def show
  end

  def edit
  end

  def update
  end

  def index
  end

  private
    def set_grading
      @grading = Grading.find(params[:id])
      @assignment = Assignment.find @grading.assignment_id
      @course = @assignment.course_id
      @grader = Enrollment.find @grading.grader_id
      @gradee = Enrollment.find @grading.gradee_id
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
