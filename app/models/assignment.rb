class Assignment < ActiveRecord::Base
  # Attributes: name, course_id, pdf, min_points, max_points, began_grading, finished_grading
  belongs_to :course, class_name: "Course"

  has_many :submissions, dependent: :destroy
  has_many :gradings, dependent: :destroy
  has_many :grades, dependent: :destroy

  validates :name, presence: true, length: { minimum: 2, maximum: 50 }
  validates :course_id, presence: true
  validates :pdf, presence: true
  
  mount_uploader :pdf, PdfUploader

  def assign_gradings
    enrollments = self.course.enrollments.where status: Statuses::STUDENT
    submissions_array = []
    enrollments.each do |enrollment|
      submissions = enrollment.submissions.where(assignment_id: self.id)
      if submissions.count > 0
        submissions_array << { enrollment_id: enrollment.id }
      end
    end
    if submissions_array.count < 4
      return submissions_array.count
    else
      submissions_array.shuffle!
      submissions_array.length.times do
        enrollment_ids = submissions_array[0..3].map { |hash| hash[:enrollment_id] }
        enrollment = Enrollment.find(enrollment_ids[0])
        enrollment_ids[1..3].each do |gradee_id|
          enrollment.add_grading_to_do(self.id, gradee_id)
        end
        submissions_array.rotate!
      end
      self.update began_grading: true
      return true
    end
  end

end
