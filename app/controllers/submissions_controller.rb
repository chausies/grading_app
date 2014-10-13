class SubmissionsController < ApplicationController
  before_action :set_course
  before_action :signed_in_user
  before_action :set_enrollment
  before_action :set_assignment
	before_action :set_submission, except: [:new, :create]
  before_action :check_submission_allowed, only: [:new, :create]
	before_action :check_access_allowed, except: [:new, :create]

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
			redirect_to configure_subparts_course_assignment_submission_path(@course, @assignment, @submission)
    else
      render :new
    end
  end

	def update
    if @submission.update submission_params
      flash[:success] = 'Successfully submitted.'
			redirect_to [@course, @assignment]
    else
      render :configure_subparts
    end
	end

  def show
  end

	def configure_subparts
		gon.total_pages = @submission.pages.count
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

    def set_submission
      @submission = @assignment.submissions.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def submission_params
			subpart_stuff = params.require(:submission)[:subparts_attributes]
			if subpart_stuff
				params.require(:submission).permit(:name, :pdf).merge subparts_attributes: subpart_stuff
			else
				params.require(:submission).permit(:name, :pdf)
			end
    end

    def check_submission_allowed
      if @assignment.began_grading or @assignment.finished_grading
        redirect_to [@course, @assignment], notice: "Submissions are no longer allowed for this assignment."
      end
    end

		def check_access_allowed
			unless @submission and (@submission.enrollment_id == @enrollment.id or @enrollment.status > Statuses::READER)
				redirect_to [@course, @assignment], notice: "You can't just look at student submissions that aren't yours ಠ_ಠ"
			end
		end

end
