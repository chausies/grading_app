class Grading < ActiveRecord::Base
  # Attributes: assignment_id, gradee (enrollment_id of gradee), grader (enrollment_id of grader), score

  belongs_to :assignment, class_name: "Assignment"
  belongs_to :gradee, foreign_key: "gradee", class_name: "Enrollment"
  belongs_to :grader, foreign_key: "grader", class_name: "Enrollment"

  validates :assignment_id, presence: true
  validates :gradee, presence: true
  validates :grader, presence: true
end
