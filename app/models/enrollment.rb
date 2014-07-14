class Enrollment < ActiveRecord::Base
  # Attributes: participant_id, course_id, status, sid, gradings_to_do
  belongs_to :participant, class_name: "User"
  belongs_to :course, class_name: "Course"

  has_many :given_grades, class_name: "Grading", foreign_key: "grader_id", dependent: :destroy
  has_many :received_grades, class_name: "Grading", foreign_key: "gradee_id", dependent: :destroy
  has_many :submissions, dependent: :destroy

  before_save do
  	self.sid = self.sid.to_s.strip if self.sid
  	unless self.id
  		self.sid = ('a'..'z').to_a.shuffle[0..7].join
  	end
  end

  validates :participant_id, presence: true
  validates :course_id, presence: true

  def status?(status)
  	self.status == status
  end

  def add_grading_to_do(assignment_id, gradee_id)
    grading = self.given_grades.create!(assignment_id: assignment_id, gradee_id: gradee_id)
  end

  def gradings_to_do
    self.given_grades.where finished_grading: false
  end

  # next grading object after last_grading_id
  def next_grading(last_grading_id = 0)
    self.given_grades.bsearch { |grade| grade.id > last_grading_id }
  end
  def prev_grading(last_grading_id = Float::INFINITY)
    self.given_grades.reverse.bsearch { |grade| grade.id < last_grading_id}
  end
  
  # next unfinished grading object after last_grading_id
  def next_grading_to_do(last_grading_id = 0)
    self.gradings_to_do.bsearch { |grade| grade.id > last_grading_id }
  end
  def prev_grading_to_do(last_grading_id = Float::INFINITY)
    self.gradings_to_do.reverse.bsearch { |grade| grade.id < last_grading_id}
  end

end
