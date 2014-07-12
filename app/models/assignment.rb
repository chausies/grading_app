class Assignment < ActiveRecord::Base
  # Attributes: name, course_id, pdf, min_points, max_points
  belongs_to :course, class_name: "Course"
  has_many :submissions, dependent: :destroy

  validates :name, presence: true, length: { minimum: 2, maximum: 50 }
  validates :course_id, presence: true
  validates :pdf, presence: true
  
  mount_uploader :pdf, PdfUploader
end
