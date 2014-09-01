class PagesSubpartsRelationship < ActiveRecord::Base
	# Attributes: subpart_id, page_id
	
	belongs_to :subpart
	belongs_to :page

end
