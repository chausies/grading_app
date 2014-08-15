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
    if @assignment.began_grading and @enrollment and @enrollment.status > Statuses::READER
      @gradings = @assignment.gradings
      @total_gradings = @gradings.count
      @finished_gradings = 0
      @grades_for_gradees = {}
      @gradings.each do |grading|
        @grades_for_gradees[grading.gradee_id] ||= 0
        if grading.finished?
          @finished_gradings += 1
          @grades_for_gradees[grading.gradee_id] += 1
        end
      end
      @needed_gradings = (@grades_for_gradees.values.map { |x| [2 - x, 0].max }).sum
    end
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

	def configure_grading
	end

  def begin_grading
    unless @assignment.began_grading
			self_grading = (params[:self_grading] == "true")
			num_stud_gradings = params[:num_stud_gradings].to_i
			num_reader_gradings = params[:num_reader_gradings].to_i
      if (submission_count=@assignment.assign_gradings(self_grading, num_stud_gradings, num_reader_gradings)) == true
        flash[:success] = "Assigned gradings to students!"
      else
				min_necessary = [num_reader_gradings, num_stud_gradings + ( self_grading ? 0 : 1)].max
        flash[:error] = "Need at least #{min_necessary} submissions to begin grading. Only have #{submission_count} so far."
      end
      redirect_to configure_grading_course_assignment_path(@course, @assignment)
    end
  end

  def end_grading 
    if @assignment.began_grading and not @assignment.finished_grading
			@gradings = @assignment.gradings
			@grades_for_gradees = {}
			@gradings.each do |grading|
				@grades_for_gradees[grading.gradee_id] ||= 0
				if grading.finished?
					@grades_for_gradees[grading.gradee_id] += 1
				end
			end
			@needed_gradings = (@grades_for_gradees.values.map { |x| [2 - x, 0].max }).sum
			if @needed_gradings > 0
				flash[:error] = "You don't have the minimum required gradings. #{view_context.pluralize(@needed_gradings, "student")} don't have a sufficient amount of gradings"
				redirect_to [@course, @assignment]
			else
				@assignment.update finished_grading: true
				@course.assign_grades
				@course.update_grading_scores
				flash[:success] = "Assigned grades to students!"
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
