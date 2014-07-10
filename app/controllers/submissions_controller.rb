class SubmissionsController < ApplicationController
  before_action :set_course
  before_action :signed_in_user
  before_action :set_enrollment
  before_action :set_assignment

  def new
    @submission = @assignment.submissions.build
  end

  def create
    @submission = @assignment.submissions.build(pdf: params[:pdf])

    if @submission.save
      flash[:success] = 'Successfully submitted.'
      redirect_to [@course, @assignment, @submission]
    else
      render :new
    end
  end

  def show
    @submission = @assignment.submissions.find(params[:id])
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_assignment
      @assignment = @course.assignments.find(params[:assignment_id])
    end

    def set_course
      @course = Course.find(params[:course_id])
    end

    def set_enrollment
      @enrollment = current_user.nil? ? false : current_user.enrollments.find_by(course_id: @course.id)
    end

    # Only allow a trusted parameter "white list" through.
    def assignment_params
      params[:submission].permit(:pdf)
    end

end
