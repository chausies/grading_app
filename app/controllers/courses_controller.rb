class CoursesController < ApplicationController
  before_action :set_course, except: [:new, :create, :index]
  before_action :signed_in_user, except: [:index, :show]
  before_action :set_enrollment, except: :index
  before_action :instructor_or_more, only: [:destroy, :import]
  before_action :TA_or_more, only: [:update, :edit, :roster]

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
  end

  def roster
    @enrollments = @course.enrollments
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
end
