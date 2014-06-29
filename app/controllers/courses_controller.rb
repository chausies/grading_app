class CoursesController < ApplicationController
  before_action :get_course, only: [:update, :edit, :destroy, :show, :roster]
  before_action :instructor_or_more, only: :destroy
  before_action :TA_or_more, only: [:update, :edit, :roster]

  def new
    @course = Course.new
  end

  def create
    @admin_users = User.where(admin: true)
    @course = Course.new(course_params)
    if @course.save
      @admin_users.each { |admin| admin.enroll!(@course) }
      sign_in @user
      flash[:success] = "Your course has been successfully created!"
      redirect_to @course
    else
      render 'new'
    end
  end

  def update
    if @course.update_attributes(course_params)
      flash[:success] = "Course profile updated"
      redirect_to @course
    else
      render 'edit'
    end
  end

  def edit
  end

  def destroy
  end

  def index
    @courses = Course.all
  end

  def show
  end

  def roster
    @participants = @course.participants
  end

  private

    def get_course
      @course = Course.find(params[:id])
    end

    def course_params
      params.require(:course).permit(:name, :subject, :school)
    end

    def instructor_or_more
      status_or_more Statuses::INSTRUCTOR
    end

    def TA_or_more
      status_or_more Statuses::TA
    end

    def status_or_more(status)
      signed_in_user
      has_permission = current_user.enrollments.find_by(course_id: @course.id).status > status
      unless has_permission
        redirect_to root_url notice: "You ain't allowed to edit the course ಠ_ಠ"
      end
    end
end
