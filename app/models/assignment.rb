class Assignment < ActiveRecord::Base
  # Attributes: name, course_id, pdf
  belongs_to :course, class_name: "Course"
  has_many :submissions, dependent: :destroy
  
  validates :name, presence: true, length: { minimum: 2, maximum: 50 }
  validates :course_id, presence: true
  mount_uploader :pdf, PdfUploader
end
