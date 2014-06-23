class Enrollment < ActiveRecord::Base
  belongs_to :participant, class_name: "User"
  belongs_to :course, class_name: "Course"
  validates :participant_id, presence: true
  validates :course_id, presence: true

  def status?(status)
    self.status == status
  end
end
