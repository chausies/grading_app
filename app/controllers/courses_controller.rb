class CoursesController < ApplicationController
  before_action :set_course, except: [:new, :create, :index]
  before_action :signed_in_user, except: [:index, :show]
  before_action :set_enrollment, except: :index
  before_action :instructor_or_more, only: [:destroy]
  before_action :TA_or_more, only: [:update, :edit, :roster, :import, :new_import, :new_enrollment, :add_enrollment, :data]

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
        @enr_hash[@enrollment][grading.assignment].append grading
      end
    end
    respond_to do |format|
      format.html
      format.csv { send_data @course.to_csv, disposition: "attachment; filename=#{@course.name.gsub(" ", "_").downcase}_grades.csv" }
      format.text { send_data @course.to_dict.to_yaml, filename: "#{@course.name.gsub(" ", "_").downcase}_data.yaml" }
    end
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
    redirect_to course_enrollments_path(@course)
  end

  def data
    respond_to do |format|
      format.html
      format.text { send_data @course.to_dict.to_yaml, filename: "#{@course.name.gsub(" ", "_").downcase}_data.yaml" }
    end
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
