class CoursesController < ApplicationController
  before_action :set_course, except: [:new, :create, :index]
  before_action :signed_in_user, except: [:index, :show]
  before_action :set_enrollment, except: :index
  before_action :instructor_or_more, only: [:destroy]
  before_action :TA_or_more, only: [:update, :edit, :roster, :import, :new_import, :new_enrollment, :add_enrollment]

  def new
    @course = Course.new
  end

  def create
    @course = Course.new(course_params)
    if @course.save
      flash[:success] = "Your course has been successfully created!"
      redirect_to @course
    else
      render 'new'
    end
  end

  def update
    if @course.update_attributes course_params
      flash[:success] = "Course profile updated"
      redirect_to @course
    else
      render 'edit'
    end
  end

  def edit
  end

  def destroy
    @course.destroy
    redirect_to courses_url, notice: 'Course was successfully destroyed.'
  end

  def index
    @courses = Course.all
  end

  def show
    @assignments = @course.assignments
    @enr_hash = {}
    if @enrollment
      @enr_hash[@enrollment] ||= {}
      @enrollment.given_gradings.reverse.each do |grading|
        @enr_hash[@enrollment][grading.assignment] ||= []
        @enr_hash[@enrollment][grading.assignment].append grading
      end
    end
    respond_to do |format|
      format.html
      format.csv { send_data @course.to_csv, disposition: "attachment; filename=#{@course.name.gsub(" ", "_").downcase}_grades.csv" }
    end
  end

  def roster
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

  def search_roster
    @suggestions = ['suggestion1', 'suggestion2', 'suggestion3']
    render json: @suggestions
  end

  def new_enrollment
  end

  def add_enrollment
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
      redirect_to new_enrollment_course_path(@course)
      return
    end
    unless student = User.find_by(email: param_hash[:email])
      student = User.create email: param_hash[:email], name: param_hash[:name], password: "testing", password_confirmation: "testing"
      if student.errors.any?
        messages.concat student.errors.full_messages
        flash[:error] = messages.join ", "
        redirect_to new_enrollment_course_path(@course)
        return
      end
    end
    if student.enrolled?(@course.id)
        redirect_to new_enrollment_course_path(@course), notice: "Participant is already enrolled. Go to the roster if you want to edit this participant's parameters"
        return
    end
    begin
      if param_hash[:status].blank?
        param_hash[:status] = Statuses::STUDENT
      else
        param_hash[:status] = Statuses.string_to_status param_hash[:status]
        if param_hash[:status].nil?
          param_hash[:status] = Statuses::STUDENT
        end
      end
      student.enroll! @course.id, param_hash[:status], param_hash[:sid]
    rescue
      flash[:error] = "Error enrolling student! Probably because SID matches that of another student."
      redirect_to new_enrollment_course_path(@course)
      return
    end
    flash[:success] = "Participant has been successfully added!"
    redirect_to @course
  end

  def new_import
  end

  def import
    message = @course.import(params[:file])
    if message == true
      flash[:success] = "Successfully imported students"
    else
      flash[:error] = message
    end
    redirect_to roster_course_path(@course)
  end

  private

    def set_course
      @course = Course.find(params[:id])
    end

    def set_enrollment
      @enrollment = (current_user and @course) ? current_user.enrollments.find_by(course_id: @course.id) : false
    end

    def course_params
      params.require(:course).permit(:name, :subject, :school)
    end

    def enrollment_params
      params.permit(:name, :email, :sid, :status)
    end

end
