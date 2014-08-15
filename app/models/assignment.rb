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

  def assign_gradings self_grading?, num_stud_gradings, num_reader_gradings
		num_other_stud_gradings = num_stud_gradings - ( self_grading? ? 1 : 0 )
    enrollments = self.course.enrollments.where status: Statuses::STUDENT
		readers = self.course.enrollments.where status: Statuses::READER
    submissions_array = []
    enrollments.each do |enrollment|
      submissions = enrollment.submissions.where(assignment_id: self.id)
      if submissions.count > 0
        submissions_array << { enrollment_id: enrollment.id }
      end
    end
    if submissions_array.count <= num_other_stud_gradings or submissions_array.count < num_reader_gradings
      return submissions_array.count
    else
      submissions_array.shuffle!
      submissions_array.length.times do
        enrollment_ids = submissions_array[0..num_other_stud_gradings].map { |hash| hash[:enrollment_id] }
        enrollment = Enrollment.find(enrollment_ids[0])
				if self_grading?
					enrollment.add_grading_to_do(self.id, enrollment.id)
				end
        enrollment_ids[1..num_other_stud_gradings].each do |gradee_id|
          enrollment.add_grading_to_do(self.id, gradee_id)
        end
        submissions_array.rotate!
      end
			submissions_array.shuffle!
			ind = 0
			readers.each |reader| do
				num_reader_gradings.times do
					reader.add_grading_to_do(self.id, submissions_array[ind][:enrollment_id])
					ind += 1
				end
			end
      self.update began_grading: true
      return true
    end
  end

end
