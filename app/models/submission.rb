class Submission < ActiveRecord::Base
	belongs_to :enrollment, class_name: "Enrollment"
	belongs_to :assignment, class_name: "Assignment"

	validates :enrollment_id, presence: true
	validates :assignment_id, presence: true
end
