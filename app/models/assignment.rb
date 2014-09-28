class Assignment < ActiveRecord::Base
  # Attributes: name, course_id, assignment_file, solution_file, min_points, max_points, began_grading, finished_grading

  default_scope -> { order('created_at DESC') }
	scope :persisted, -> { where "id IS NOT NULL" }
	
  belongs_to :course, class_name: "Course"

  has_many :submissions, dependent: :destroy
  has_many :gradings, dependent: :destroy
  has_many :grades, dependent: :destroy
	has_many :subparts, as: :parent, dependent: :destroy
	# has_many :assignment_pages, dependent: :destroy, class_name: "Page", foreign_key: "assignment_id"
	has_many :solution_pages, dependent: :destroy, class_name: "Page", foreign_key: "solution_id"

	accepts_nested_attributes_for :subparts, allow_destroy: true

  validates :name,      presence: true, length: { minimum: 2, maximum: 50 }
  validates :course_id, presence: true
  
  mount_uploader :assignment_file, PdfUploader
	mount_uploader :solution_file,   PdfUploader

	# after_save :update_assignment_pages
	after_save :update_solution_pages

	def min_points
		if self.subparts.any?
			(self.subparts.map { |s| s.min_points }).sum
		else
			read_attribute(:min_points)
		end
	end

	def max_points
		if self.subparts.any?
			(self.subparts.map { |s| s.max_points }).sum
		else
			read_attribute(:max_points)
		end
	end

  def assign_gradings self_grading, num_stud_gradings, num_reader_gradings
		num_other_stud_gradings = num_stud_gradings - ( self_grading ? 1 : 0 )
    enrollments = self.course.enrollments.where status: Statuses::STUDENT
		readers = self.course.enrollments.where status: Statuses::READER
    submissions_array = []
    enrollments.each do |enrollment|
      submissions = enrollment.submissions.where(assignment_id: self.id)
      if submissions.any?
        submissions_array << { enrollment_id: enrollment.id }
      end
    end
    if submissions_array.count <= num_other_stud_gradings or submissions_array.count < num_reader_gradings
      return submissions_array.count
    else
			leaves = self.subpart_leaves
			leaves = [nil] if leaves.empty?
			leaves.each do |subpart|
				subpart_id = subpart ? subpart.id : nil
				submissions_array.shuffle!
				submissions_array.length.times do
					enrollment_ids = submissions_array[0..num_other_stud_gradings].map { |hash| hash[:enrollment_id] }
					enrollment = Enrollment.find(enrollment_ids[0])
					if self_grading
						enrollment.add_grading_to_do(self.id, subpart_id, enrollment.id)
					end
					enrollment_ids[1..num_other_stud_gradings].each do |gradee_id|
						enrollment.add_grading_to_do(self.id, subpart_id, gradee_id)
					end
					submissions_array.rotate!
				end
				submissions_array.shuffle!
				ind = 0
				readers.each do |reader|
					num_reader_gradings.times do
						reader.add_grading_to_do(self.id, subpart_id, submissions_array[ind][:enrollment_id])
						ind += 1
					end
				end
			end
      self.update began_grading: true
      return true
    end
  end

	def subpart_leaves
		stack = []
		leaves = []
		self.subparts.each { |s| stack.push s }
		while stack.any?
			s = stack.pop
			if s.children.any?
				s.children.each { |c| stack.push c }
			else
				leaves.push s
			end
		end
		leaves.reverse
	end

	def get_subpart index_arr_or_index_str
		if index_arr_or_index_str.is_a? String
			index_arr = index_arr_or_index_str.split('.').map! { |str| str.to_i }
		else
			index_arr = Array.new(index_arr_or_index_str)
		end
		index_arr.map! { |ind| ind - 1 }
		ind = index_arr.shift
		if self.subparts.count <= ind
			subpart = nil
		else
			subpart = self.subparts[ind]
			while index_arr.any?
				ind = index_arr.shift
				if subpart.children.count <= ind
					subpart = nil
					break
				else
					subpart = subpart.children[ind]
				end
			end
		end
		subpart
	end

	private

		def update_assignment_pages
			if assignment_file_changed? and assignment_file
				self.assignment_pages.destroy_all
				assignment_file.grim.each_with_index do |page, i|
					temp = Tempfile.new ["assignment_page_#{i + 1}_", ".png"]
					begin
						page.save temp.path
						self.assignment_pages.create! page_num: (i + 1), page_file: temp
					ensure
						temp.close
						temp.unlink
					end
				end
			end
		end

		def update_solution_pages
			if solution_file_changed? and solution_file
				self.solution_pages.destroy_all
				solution_file.grim.each_with_index do |page, i|
					temp = Tempfile.new ["soln_page_#{i + 1}_", ".png"]
					begin
						page.save temp.path
						self.solution_pages.create! page_num: (i + 1), page_file: temp
					ensure
						temp.close
						temp.unlink
					end
				end
			end
		end

end
