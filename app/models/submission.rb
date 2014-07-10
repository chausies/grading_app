class Submission < ActiveRecord::Base
  # Attributes: assignment_id, course_id, created_at
  default_scope -> { order('created_at DESC') }
  belongs_to :enrollment, class_name: "Enrollment"
  belongs_to :assignment, class_name: "Assignment"

  validates :enrollment_id, presence: true
  validates :assignment_id, presence: true
end
