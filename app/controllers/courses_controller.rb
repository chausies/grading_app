class CoursesController < ApplicationController
  protect_from_forgery :except => [:api, :api_submit]
  before_action :set_course, except: [:new, :create, :index]
  before_action :signed_in_user, except: [:index, :show, :api, :api_submit]
  before_action :set_enrollment, except: [:index, :api_submit]
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
      format.text { send_data @course.yaml_dict, filename: "#{@course.name.gsub(" ", "_").downcase}_data.yaml" }
    end
  end

  def api
  end

  def api_submit
    if not params[:file]
      flash[:error] = "Please submit a valid YAML file"
    else
      commands = YAML.load_file params[:file].tempfile
      credentials = (commands.find { |command| command["credentials"] })["credentials"]
      commands.delete_if { |command| command["credentials"] }
      if not credentials
        flash[:error] = "Didn't submit any credentials. See the examples for more info."
      else
        user = User.find_by(email: credentials["email"].downcase)
        if !user
          flash[:error] = 'This email is not registered'
        elsif !user.authenticate(credentials["password"])
          flash[:error] = 'Invalid password'
        else
          enrollment = user.enrollments.find_by(course_id: params[:id])
          if not enrollment
            flash[:error] = "User given by credentials isn't enrolled in the course"
          elsif enrollment.status <= Statuses::READER
            flash[:error] = "User given by credentials doesn't have permissions. Must be TA or higher."
          else
            # All credentials pass
            success_messages = []
            commands.each do |command|
              success, messages = @course.execute_command(command, params["assignment_file"], params["solution_file"])
              if not success
                flash[:error] = messages
                break
              else
                success_messages.push *messages
              end
            end
            if flash[:error].blank?
              flash[:success] = success_messages
            end
          end
        end
      end
    end
    redirect_to api_course_path(@course)
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
