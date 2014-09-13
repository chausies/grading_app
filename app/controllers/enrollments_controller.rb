class EnrollmentsController < ApplicationController
  before_action :set_course
  before_action :signed_in_user
  before_action :set_enrollment
	before_action :TA_or_more, except: [:show]

  def new
    @new_enrollment = @course.enrollments.build
  end

  def create
    messages = []
    param_hash = enrollment_params
    if param_hash[:email].blank?
      messages.append( "Email can't be blank" )
    end
    if param_hash[:name].blank?
      param_hash[:name] = "testing"
    end
    if messages.any?
      flash[:error] = messages.join ", "
      redirect_to new_course_enrollment_path(@course)
      return
    end
    unless student = User.find_by(email: param_hash[:email])
      student = User.create email: param_hash[:email], name: param_hash[:name], password: "testing", password_confirmation: "testing"
      if student.errors.any?
        messages.concat student.errors.full_messages
        flash[:error] = messages.join ", "
        redirect_to new_course_enrollment_path(@course)
        return
      end
    end
    if student.enrolled?(@course.id)
        redirect_to new_course_enrollment_path(@course), notice: "Participant is already enrolled. Go to the roster if you want to edit this participant's parameters"
        return
    end
    begin
      if param_hash[:status].blank?
        param_hash[:status] = Statuses::STUDENT
      else
        if param_hash[:status].nil?
          param_hash[:status] = Statuses::STUDENT
        end
      end
      student.enroll! @course.id, param_hash[:status], param_hash[:sid]
    rescue
      flash[:error] = "Error enrolling student! Probably because SID matches that of another student."
      redirect_to new_course_enrollment_path(@course)
      return
    end
    flash[:success] = "Participant has been successfully added!"
    redirect_to course_enrollments_path(@course)
  end

  def edit
		@new_enrollment = @course.enrollments.all.find(params[:id])
  end

  def update
		@new_enrollment = @course.enrollments.all.find(params[:id])
    if @new_enrollment.update_attributes enrollment_params
      flash[:success] = "Enrollment updated"
      redirect_to [@course, @new_enrollment]
    else
      render 'edit'
    end
  end

  def destroy
		@new_enrollment = @course.enrollments.all.find(params[:id])
    @new_enrollment.destroy
    redirect_to course_enrollments_path(@course), notice: 'Enrollment was successfully destroyed.'
  end

  def index
    if params[:search]
      @enrollments = @course.enrollments.joins(:participant).
                        where('"users"."name" LIKE :query OR "users"."email" LIKE :query OR sid LIKE :query',
                                 query: "#{params[:search]}%")
    else
        @enrollments = @course.enrollments
    end
    @enrollments = @enrollments.to_a.sort do |a, b|
      if a.status?(b.status)
        # ASC order of name
        a.participant.name.downcase <=> b.participant.name.downcase
      else
        # DESC order of status
        b.status <=> a.status
      end
    end
  end

  def show
		@new_enrollment = @course.enrollments.all.find(params[:id])
    @assignments = @course.assignments
    @enr_hash = {}
		@enr_hash[@new_enrollment] ||= {}
		@new_enrollment.given_gradings.reverse.each do |grading|
			@enr_hash[@new_enrollment][grading.assignment] ||= []
			@enr_hash[@new_enrollment][grading.assignment].append grading
		end
  end

  private

    def set_course
      @course = Course.find(params[:course_id])
    end

    def set_enrollment
      @enrollment = (current_user and @course) ? current_user.enrollments.find_by(course_id: @course.id) : false
    end

    def enrollment_params
      params.require(:enrollment).permit(:sid, :status).merge params.permit(:name, :email)
    end

end
