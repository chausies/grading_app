class Course < ActiveRecord::Base
  # Attributes: name, subject, school
  include ActionView::Helpers::TextHelper

  has_many :enrollments, foreign_key: "course_id", dependent: :destroy
  has_many :participants, through: :enrollments
  has_many :assignments, dependent: :destroy

  validates :name, presence: true, length: { minimum: 2, maximum: 50 }
  validates :school, presence: true, length: { minimum: 2, maximum: 50 }

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
      "email"                 =>  "email",
      "email address"         =>  "email",
      "address"               =>  "email",
      "student email"         =>  "email",
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
      if stud_hash[:name].nil? or stud_hash[:name].empty?
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
        student.enroll! id, Statuses::STUDENT, stud_hash[:sid]
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

end
