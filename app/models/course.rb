class Course < ActiveRecord::Base
  # Attributes: name, subject, school
  include ActionView::Helpers::TextHelper
  
  default_scope -> { order('id ASC') }
  has_many :enrollments, foreign_key: "course_id", dependent: :destroy
  has_many :participants, through: :enrollments
  has_many :assignments, dependent: :destroy

  validates :name, presence: true, length: { minimum: 2, maximum: 50 }
  validates :school, presence: true, length: { minimum: 2, maximum: 50 }

  after_create :enroll_admins

  def import(file)
  # Returns true if import successful, else returns an error message
    message = ""
    if file.nil? or file.content_type != 'text/csv'
      return message = "We currently only support csv files."
    end
    student_params = {
      "name"                  =>  "name",
      "student name"          =>  "name",
      "sid"                   =>  "sid",
      "student id number"     =>  "sid",
      "student id"            =>  "sid",
      "id #"                  =>  "sid",
      "identification number" =>  "sid",
      "id number"             =>  "sid",
      "email"                 =>  "email",
      "email address"         =>  "email",
      "address"               =>  "email",
      "student email"         =>  "email",
      "status"                =>  "status",
      "role"                  =>  "status",
      "type"                  =>  "status"
    }
    bad_strings = []
    match = lambda do |string|
      string.downcase!
      match = student_params.max { |a,b| a[0].levenshtein_similar(string) <=> b[0].levenshtein_similar(string) }
      if string.levenshtein_similar(match[0]) < 0.4
        bad_strings.append string
      end
      match[1].to_sym
    end
    CSV.foreach file.path, headers: true, header_converters: match do |row|
      break if !bad_strings.empty?
      stud_hash = row.to_hash.each { |_, str| str.strip! }
      if stud_hash[:email].nil?
        return message = "Email required for the following student: " + stud_hash.to_s
      end
      if stud_hash[:name].blank?
        stud_hash[:name] = "testing"
      end
      unless student = User.find_by(email: stud_hash[:email])
        student = User.create email: stud_hash[:email], name: stud_hash[:name], password: "testing", password_confirmation: "testing"
        if student.errors.any?
          return message = "Error for following student: " + stud_hash.to_s + ". Error content: " + student.errors.full_messages.first
        end
      end
      if student.enrolled?(id)
        next
      end
      begin
        if stud_hash[:status].blank?
          stud_hash[:status] = Statuses::STUDENT
        else
          stud_hash[:status] = Statuses.string_to_status stud_hash[:status]
          if stud_hash[:status].nil?
            stud_hash[:status] = Statuses::STUDENT
          end
        end
        student.enroll! id, stud_hash[:status], stud_hash[:sid]
      rescue
        return message = "Error for the following student: " + stud_hash.to_s + ". Probably because SID matches that of another student."
      end
    end
    if !bad_strings.empty?
      message = "Couldn't find good match for the following #{pluralize(bad_strings.length, "parameter")}: " + bad_strings.join(", ")
    end
    if message.empty?
      true
    else
      message
    end
  end

  def assign_grades
    assignments = self.assignments.where finished_grading: true
    enrollments = self.enrollments
    assignments.each do |assignment|
      touched_enrollments = []
      grading_hash = {}
      assignment.gradings.each do |g|
        if g.finished?
          grading_hash[g.gradee] ||= []
          grading_hash[g.gradee].append g.score
        end
      end
      grading_hash.each do |enrollment, assigned_grades|
        enrollment.assign_grade(assignment.id, assigned_grades.sum.to_f/assigned_grades.size)
        touched_enrollments.append enrollment.id
      end
      touched_enrollments = touched_enrollments.to_set
      gets_zero = enrollments.to_a.delete_if { |e| touched_enrollments.member? e.id }
      gets_zero.each { |e| e.assign_grade(assignment.id, assignment.min_points) }
    end
  end

  def update_grading_scores
    assignments = self.assignments.where(finished_grading: true).map { |assignment| assignment.id }
    self.enrollments.where(status: [Statuses::STUDENT, Statuses::READER]).each do |e|
      gradings = e.given_gradings.where assignment_id: assignments, finished_grading: true
      if gradings.any?
        relative_errors = gradings.map { |g| (g.score - g.gradee.score_for(g.assignment_id)).abs.to_f/(g.assignment.max_points - g.assignment.min_points) }
        e.update grading_score: 100 - 100*relative_errors.sum/relative_errors.size
      end
    end
  end

  private
    def enroll_admins
      admin_users = User.where admin: true
      admin_users.each { |admin| admin.enroll! self, Statuses::ADMIN }
    end
end
