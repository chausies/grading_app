class AssignmentsController < ApplicationController
  before_action :set_course
  before_action :signed_in_user
  before_action :set_enrollment
  before_action :set_assignment, except: [:index, :new, :create]
  before_action :TA_or_more, except: [:index, :show]

  # GET /assignments
  def index
    @assignments = @course.assignments
  end

  # GET /assignments/1
  def show
  end

  # GET /assignments/new
  def new
    @assignment = @course.assignments.build
  end

  # GET /assignments/1/edit
  def edit
  end

  # POST /assignments
  def create
    @assignment = @course.assignments.build(assignment_params)

    if @assignment.save
      flash[:success] = 'Assignment was successfully created.'
      redirect_to [@course, @assignment]
    else
      render :new
    end
  end

  # PATCH/PUT /assignments/1
  def update
    if @assignment.update(assignment_params)
      flash[:success] = 'Assignment was successfully updated.'
      redirect_to [@course, @assignment]
    else
      render :edit
    end
  end

  # DELETE /assignments/1
  def destroy
    @assignment.destroy
    redirect_to course_assignments_url(@course), notice: 'Assignment was successfully destroyed.'
  end

  def begin_grading
    unless @assignment.began_grading
      enrollments = @course.enrollments
      submissions_array = []
      enrollments.each do |enrollment|
        submissions = enrollment.submissions.where(assignment_id: @assignment.id)
        if submissions.count > 0
          submissions_array << { enrollment_id: enrollment.id }
        end
      end
      if submissions_array.count < 4
        flash[:error] = "Need at least 4 submissions to begin grading. Only have #{submissions_array.count} so far."
        redirect_to [@course, @assignment]
      else
        submissions_array.shuffle!
        submissions_array.length.times do
          enrollment_ids = submissions_array[0..3].map { |hash| hash[:enrollment_id] }
          enrollment = Enrollment.find(enrollment_ids[0])
          enrollment_ids[1..3].each do |gradee_id|
            enrollment.add_grading_to_do(@assignment.id, gradee_id)
          end
          submissions_array.rotate!
        end
        @assignment.began_grading = true
        flash[:success] = "Assigned gradings to students"
        redirect_to [@course, @assignment]
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_assignment
      @assignment = @course.assignments.find(params[:id])
    end

    def set_course
      @course = Course.find(params[:course_id])
    end

    def set_enrollment
      @enrollment = current_user.nil? ? false : current_user.enrollments.find_by(course_id: @course.id)
    end

    # Only allow a trusted parameter "white list" through.
    def assignment_params
      params[:assignment].permit(:name, :pdf, :max_points, :min_points)
    end
end
