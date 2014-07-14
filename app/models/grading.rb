class Grading < ActiveRecord::Base
  # Attributes: assignment_id, gradee_id (enrollment_id of gradee), grader_id (enrollment_id of grader),
  #               score, finished_grading
  belongs_to :assignment, class_name: "Assignment"
  belongs_to :gradee, class_name: "Enrollment"
  belongs_to :grader, class_name: "Enrollment"

  validates :assignment_id, presence: true
  validates :gradee_id, presence: true
  validates :grader_id, presence: true
  validate :valid_or_nil_score, on: :create
  validate :valid_score, on: :update

  private
    def valid_or_nil_score
      unless self.score.nil?
        valid_score
      end
    end

    def valid_score
      if self.score.nil?
        errors.add(:score, "must be present")
      elsif not self.score.is_a? Numeric
        errors.add(:score, "must be a number")
      elsif self.score > self.assignment.max_points
        errors.add(:score, "must be less than the max score for the assignment (#{self.assignment.max_points})")
      elsif self.score < self.assignment.min_points
        errors.add(:score, "must be more than the min score for the assignment (#{self.assignment.min_points})")
      end        
    end
end
