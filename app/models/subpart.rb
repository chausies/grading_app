class Subpart
  # Attributes: name, file, parent_id, parent_type, min_points, max_points 
	
	has_many :children, class_name: "Subpart", as: :parent, dependent: :destroy
	belongs_to :parent, polymorphic: true

  validates :parent_id, presence: true
  validates :parent_type, presence: true
end
