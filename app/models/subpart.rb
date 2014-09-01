class Subpart < ActiveRecord::Base
  # Attributes: name, index, parent_id, parent_type, min_points, max_points, pages

  default_scope -> { order('id ASC') }
	
	belongs_to :parent,   polymorphic: true
	has_many   :children, class_name: "Subpart", as: :parent, dependent: :destroy
	has_many   :pages,    through: :pages_subparts_relationships
	has_many   :pages_subparts_relationships, dependent: :destroy

	accepts_nested_attributes_for :children,                     allow_destroy: true
	accepts_nested_attributes_for :pages_subparts_relationships, allow_destroy: true

  # validates :parent_id, presence: true
  # validates :parent_type, presence: true

	serialize :pages, Array

	def index
		if parent_type == "Subpart"
			self.parent.index + ".#{ self.parent.children.index(self) + 1 }"
		else
			(self.parent.subparts.index(self) + 1).to_s
		end
	end

end
