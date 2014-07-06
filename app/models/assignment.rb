class Assignment < ActiveRecord::Base
  # Attributes: name, course_id
  belongs_to :course, class_name: "Course"
end
