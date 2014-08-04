class SubmissionsController < ApplicationController
  before_action :set_course
  before_action :signed_in_user
  before_action :set_enrollment
  before_action :set_assignment
  before_action :check_submission_allowed, only: [:new, :create]

  def new
    if @assignment.began_grading
      redirect_to [@course, @assignment], notice: "Submissions for this assignment have closed."
    else
      @submission = @assignment.submissions.build
    end
  end

  def create
    @submission = @assignment.submissions.build(submission_params.merge(enrollment_id: @enrollment.id))

    if @submission.save
      flash[:success] = 'Successfully submitted.'
      redirect_to [@course, @assignment]
    else
      render :new
    end
  end

  def show
    @submission = @assignment.submissions.find(params[:id])
    unless @submission and (@submission.enrollment_id == @enrollment.id or @enrollment.status > Statuses::READER)
      redirect_to [@course, @assignment], notice: "You can't just look at student submissions that aren't yours ಠ_ಠ"
    end
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
    def submission_params
      params[:submission].permit(:pdf)
    end

    def check_submission_allowed
      if @assignment.began_grading or @assignment.finished_grading
        redirect_to [@course, @assignment], notice: "Submissions are no longer allowed for this assignment."
      end
    end

end
