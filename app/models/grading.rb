class Grading < ActiveRecord::Base
  # Attributes: assignment_id, gradee_id (enrollment_id of gradee), grader_id (enrollment_id of grader),
  #               score, finished_grading
  belongs_to :assignment, class_name: "Assignment"
  belongs_to :gradee, class_name: "Enrollment"
  belongs_to :grader, class_name: "Enrollment"

  validates :assignment_id, presence: true
  validates :gradee_id, presence: true
  validates :grader_id, presence: true
end
