module AssignmentsHelper

  def assign_gradings(course, assignment)
    enrollments = course.enrollments.where status: Statuses::STUDENT
    submissions_array = []
    enrollments.each do |enrollment|
      submissions = enrollment.submissions.where(assignment_id: assignment.id)
      if submissions.count > 0
        submissions_array << { enrollment_id: enrollment.id }
      end
    end
    if submissions_array.count < 4
      return false
    else
      submissions_array.shuffle!
      submissions_array.length.times do
        enrollment_ids = submissions_array[0..3].map { |hash| hash[:enrollment_id] }
        enrollment = Enrollment.find(enrollment_ids[0])
        enrollment_ids[1..3].each do |gradee_id|
          enrollment.add_grading_to_do(assignment.id, gradee_id)
        end
        submissions_array.rotate!
      end
      assignment.update began_grading: true
      return true
    end
  end

  def assign_grades(course)
    assignments = course.assignments.where finished_grading: true
    assignments.each do |assignment|
      grading_hash = {}
      assignment.gradings.each do |g|
        if g.finished?
          grading_hash[g.gradee] ||= []
          grading_hash[g.gradee].append g.score
        end
      end
      grading_hash.each do |enrollment, assigned_grades|
        enrollment.assign_grade(assignment.id, assigned_grades.sum/assigned_grades.size)
      end
    end
  end

  def update_grading_scores(course)
    assignments = course.assignments.where(finished_grading: true).map { |assignment| assignment.id }
    course.enrollments.where(status: [Statuses::STUDENT, Statuses::READER]).each do |e|
      gradings = e.gradings.where assignment_id: assignments, finished_grading: true
      relative_errors = gradings.map { |g| (g.score - g.gradee.score_for(g.assignment_id)).abs.to_f/(g.assignment.max_points - g.assignment.min_points) }
      e.update grading_score: 100*relative_errors.sum/relative_errors.size
    end
  end
end
