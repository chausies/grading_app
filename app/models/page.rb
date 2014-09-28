class Page < ActiveRecord::Base
  # Attributes: page_num, page_file, parent_id parent_type
	
	# belongs_to :assignment, class_name: "Assignment", foreign_key: "assignment_id"
	belongs_to :solution,   class_name: "Assignment", foreign_key: "solution_id"
	belongs_to :submission

	has_many   :pages_subparts_relationships, dependent: :destroy
	has_many   :subparts,                     through: :pages_subparts_relationships

	validate :only_one_parent

	mount_uploader :page_file, ImgUploader
	
	private

		def only_one_parent
			if [self.assignment_id, self.solution_id, self.submission_id].reject(&:blank?).size !=1
				errors.add(:page, "must have exactly one parent")
			end
		end
end
