class Submission < ActiveRecord::Base
  # Attributes: assignment_id, enrollment_id, created_at
  default_scope -> { order('created_at DESC') }
	scope :persisted, -> { where "id IS NOT NULL" }

  belongs_to :enrollment, class_name: "Enrollment"
  belongs_to :assignment, class_name: "Assignment"
	has_many :subparts, as: :parent, dependent: :destroy
	has_many :pages, dependent: :destroy
	
	accepts_nested_attributes_for :subparts, allow_destroy: true

  validates :enrollment_id, presence: true
  validates :assignment_id, presence: true
  
  mount_uploader :pdf, PdfUploader

	after_create :create_subparts
	after_save :update_pages

	def get_subpart index_arr_or_index_str
		if index_arr_or_index_str.is_a? String
			index_arr = index_arr_or_index_str.split('.').map! { |str| str.to_i }
		else
			index_arr = index_arr_or_index_str
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

		def create_subparts
			queue = []
			self.assignment.subparts.each do |ass_subpart| 
				subm_subpart = self.subparts.create! name: ass_subpart.name
				queue.push [ass_subpart, subm_subpart]
			end
			while queue.any?
				ass_subpart, subm_subpart = queue.shift
				if ass_subpart.children.any?
					ass_subpart.children.each do |new_ass_subpart|
						new_subm_subpart = subm_subpart.children.create! name: new_ass_subpart.name
						queue.push [new_ass_subpart, new_subm_subpart]
					end
				end
			end
			true
		end

		def update_pages
			if pdf_changed? and pdf
				self.pages.destroy_all
				path = pdf.get_path
				reader = PDF::Reader.new(path)
				reader.page_count.times do |i|
					self.pages.create! page_num: (i+1)
				end
				metajob = MetaJob.create_job PageJob.new(:submission, self.id, :pdf), "Submission #{self.id} PDF"
			end
		end

end
