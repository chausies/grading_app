class AssignmentsController < ApplicationController
  before_action :set_course
  before_action :set_assignment, only: [:show, :edit, :update, :destroy]

  # GET /assignments
  def index
    @assignments = @course.assignments
  end

  # GET /assignments/1
  def show
  end

  # GET /assignments/new
  def new
    @assignment = @course.build
  end

  # GET /assignments/1/edit
  def edit
  end

  # POST /assignments
  def create
    @assignment = @course.build(assignment_params)

    if @assignment.save
      flash[:success] = 'Assignment was successfully created.'
      redirect_to @assignment
    else
      render :new
    end
  end

  # PATCH/PUT /assignments/1
  def update
    if @assignment.update(assignment_params)
      flash[:success] = 'Assignment was successfully updated.'
      redirect_to @assignment
    else
      render :edit
    end
  end

  # DELETE /assignments/1
  def destroy
    @assignment.destroy
    redirect_to course_assignments_url, notice: 'Assignment was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_assignment
      @assignment = @course.assignments.find(params[:id])
    end

    def set_course
      @course = Course.find(params[:course_id])
    end

    # Only allow a trusted parameter "white list" through.
    def assignment_params
      params[:assignment]
    end
end
