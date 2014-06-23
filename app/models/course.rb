class Course < ActiveRecord::Base
  has_many :enrollments, foreign_key: "course_id", dependent: :destroy
  has_many :participants, through: :enrollments

  validates :name, presence: true, length: { minimum: 2, maximum: 50 }
  validates :school, presence: true, length: { minimum: 2, maximum: 50 }
end
