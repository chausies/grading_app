class Subpart < ActiveRecord::Base
  # Attributes: name, index, parent_id, parent_type, min_points, max_points 

  default_scope -> { order('id ASC') }
	
	has_many :children, class_name: "Subpart", as: :parent, dependent: :destroy
	belongs_to :parent, polymorphic: true

  validates :parent_id, presence: true
  validates :parent_type, presence: true

	before_save do
		if parent_type == "Subpart"
			self.index = parent.index + ".#{parent.children.count + 1}"
		else
			self.index = "#{parent.subparts.count + 1}"
		end
	end
end
