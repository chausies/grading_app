class Statuses
  ###### Enrollment Statuses ######
  STUDENT = '1student'
  READER = '2reader'
  TA = '3ta'
  INSTRUCTOR = '4instructor'
  ADMIN = '5admin'

  # e.g. check if 'user' is a student for course # course_id:
  #     user.enrollments.find_by(course_id: course_id).status?(Statuses::STUDENT)

  # Can compare statuses
  # e.g. #do stuff# if enrollment.status >= Statuses::STUDENT

  # Converts a status to a string. '.titleize' can be called afterwards
  def Statuses.status_to_string status
    case status
    when STUDENT
      "student"
    when READER
      "reader" 
    when TA
      "teaching assistant"
    when INSTRUCTOR
      "instructor"
    when ADMIN
      "admin"
    else
      
    end
  end

  # Given a string, returns the most likely status, or nil if there is no sufficiently close match
  def Statuses.string_to_status string
    correspondence = {
      "student"               =>  STUDENT,
      "stud"                  =>  STUDENT,
      "reader"                =>  READER,
      "grader"                =>  READER,
      "hired grader"          =>  READER,
      "paid grader"           =>  READER,
      "ta"                    =>  TA,
      "teaching assistant"    =>  TA,
      "teachers assistant"    =>  TA,
      "instructor"            =>  INSTRUCTOR,
      "teacher"               =>  INSTRUCTOR,
      "professor"             =>  INSTRUCTOR
    }
    string.downcase!
    match = correspondence.max { |a,b| a[0].levenshtein_similar(string) <=> b[0].levenshtein_similar(string) }
    if string.levenshtein_similar(match[0]) < 0.4
      nil
    else
      match[1].to_sym
    end
  end

  def Statuses.get_status_strings
    statuses = [
                "student",
                "reader",
                "teacher's assistant",
                "instructor"
              ]
    statuses.map { |s| s.titleize }
  end
end