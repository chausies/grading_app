module AssignmentsHelper

  def assign_gradings
    enrollments = @course.enrollments.where status: Statuses::STUDENT
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
      @assignment.update began_grading: true
      flash[:success] = "Assigned gradings to students"
      redirect_to [@course, @assignment]
    end
  end

  def assign_grades
    assignments = @course.assignments.where finished_grading: true
    enrollments = @course.enrollments.where status: Statuses::STUDENT

    @gradings = @assignment.gradings
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

  def update_grading_scores

  end
end
