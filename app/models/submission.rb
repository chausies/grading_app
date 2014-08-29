class Submission < ActiveRecord::Base
  # Attributes: assignment_id, enrollment_id, created_at
  default_scope -> { order('created_at DESC') }
	scope :persisted, -> { where "id IS NOT NULL" }

  belongs_to :enrollment, class_name: "Enrollment"
  belongs_to :assignment, class_name: "Assignment"
	has_many :children, class_name: "Subpart", as: :parent, dependent: :destroy

  validates :enrollment_id, presence: true
  validates :assignment_id, presence: true
  validates :pdf, presence: true
  
  mount_uploader :pdf, PdfUploader
end
