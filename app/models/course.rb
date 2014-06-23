class Course < ActiveRecord::Base
  has_many :enrollments, foreign_key: "course_id", dependent: :destroy
  has_many :participants, through: :enrollments
end
