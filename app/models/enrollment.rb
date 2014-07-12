class Enrollment < ActiveRecord::Base
  # Attributes: participant_id, course_id, status, sid, gradings_to_do
  belongs_to :participant, class_name: "User"
  belongs_to :course, class_name: "Course"
  
  has_many :submissions, dependent: :destroy
  
  serialize :gradings_to_do, Array

  before_save do
  	self.sid = sid.to_s.strip if self.sid
  	unless self.id
  		self.sid = ('a'..'z').to_a.shuffle[0..7].join
  	end
  end

  validates :participant_id, presence: true
  validates :course_id, presence: true

  def status?(status)
  	self.status == status
  end
end
