class Enrollment < ActiveRecord::Base
  # Attributes: participant_id, course_id, status, sid, grading_score
  default_scope -> { order('id ASC') }
	scope :persisted, -> { where "id IS NOT NULL" }

  belongs_to :participant, class_name: "User"
  belongs_to :course, class_name: "Course"

  has_many :given_gradings, class_name: "Grading", foreign_key: "grader_id", dependent: :destroy
  has_many :received_gradings, class_name: "Grading", foreign_key: "gradee_id", dependent: :destroy
  has_many :submissions, dependent: :destroy
  has_many :grades, dependent: :destroy

  before_save do
  	self.sid = self.sid.to_s.strip if self.sid
  	if self.sid.blank?
  		self.sid = ('a'..'z').to_a.shuffle[0..7].join
  	end
  end

  validates :participant_id, presence: true
  validates :course_id, presence: true

  def status?(status)
  	self.status == status
  end

	# subpart_id's are for the assignment's subpart, not the submission's subpart
  def assign_grade(assignment_id, subpart_id, score)
    grade = self.grades.where(assignment_id: assignment_id, subpart_id: subpart_id).first
    if grade
      grade.update score: score
    else
      self.grades.create! assignment_id: assignment_id, subpart_id: subpart_id, score: score
    end
  end

  def score_for(assignment_id, subpart_id=nil)
		assignment = Assignment.find(assignment_id)
		subpart = subpart_id && Subpart.find(subpart_id)
		if ((not subpart) and assignment.subparts.any?)
			(assignment.subparts.map { |s| self.score_for(assignment_id, s.id)}).sum
		elsif (subpart and subpart.children.any?)
			(subpart.children.map { |s| self.score_for(assignment_id, s.id)}).sum
		else
			grade = self.grades.find_by(assignment_id: assignment_id, subpart_id: subpart_id)
			if grade
				score = grade.score
			else
				grade
			end
		end
  end

  def add_grading_to_do(assignment_id, subpart_id, gradee_id)
    grading = self.given_gradings.create!(assignment_id: assignment_id, gradee_id: gradee_id, subpart_id: subpart_id)
  end

  def gradings_to_do
    self.given_gradings.where finished_grading: false
  end

  # next grading object after last_grading_id
  def next_grading(last_grading_id = 0)
    self.given_gradings.bsearch { |grade| grade.id > last_grading_id }
  end
  def prev_grading(last_grading_id = Float::INFINITY)
    self.given_gradings.reverse.bsearch { |grade| grade.id < last_grading_id}
  end
  
  # next unfinished grading object after last_grading_id
  def next_grading_to_do(last_grading_id = 0)
    self.gradings_to_do.bsearch { |grade| grade.id > last_grading_id }
  end
  def prev_grading_to_do(last_grading_id = Float::INFINITY)
    self.gradings_to_do.reverse.bsearch { |grade| grade.id < last_grading_id}
  end

end
