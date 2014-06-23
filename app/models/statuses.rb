class Statuses
  ###### Enrollment Statuses ######
  STUDENT = 'a'
  READER = 'b'
  INSTRUCTOR = 'c'
  ADMIN = 'd'

  # e.g. check if 'user' is a student for course # course_id:
  #     user.enrollments.find_by(course_id: course_id).status?(Statuses::STUDENT)
  # Can compare statuses
  # e.g. #do stuff# if enrollment.status >= Statuses::STUDENT
end