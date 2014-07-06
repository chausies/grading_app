class Assignment < ActiveRecord::Base
  # Attributes: name, course_id
  belongs_to :course, class_name: "Course"
  validates :name, presence: true, length: { minimum: 2, maximum: 50 }
  validates :course_id, presence: true
end
