class Grade < ActiveRecord::Base
	scope :persisted, -> { where "id IS NOT NULL" }

	belongs_to :assignment
  belongs_to :enrollment
	belongs_to :subpart

  validates :assignment_id, presence: true
  validates :enrollment_id, presence: true
  validate :valid_score


  private

    def valid_score
      if self.score.nil?
        errors.add(:score, "must be present")
      elsif not self.score.is_a? Numeric
        errors.add(:score, "must be a number")
			elsif self.subpart
				if self.score > self.subpart.max_points
					errors.add(:score, "must be less than the max score for the subpart (#{self.subpart.max_points})")
				elsif self.score < self.subpart.min_points
					errors.add(:score, "must be more than the min score for the subpart (#{self.subpart.min_points})")
				end        
			else
				if self.score > self.assignment.max_points
					errors.add(:score, "must be less than the max score for the assignment (#{self.assignment.max_points})")
				elsif self.score < self.assignment.min_points
					errors.add(:score, "must be more than the min score for the assignment (#{self.assignment.min_points})")
				end        
			end
    end
end
