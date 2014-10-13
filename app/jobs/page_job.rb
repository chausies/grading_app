PageJob = Struct.new(:model_type, :model_id, :file_type) do
	def perform
		pages = nil
		case [model_type, file_type]
		when [:assignment, :solution_file]
			pages = :solution_pages
		when [:assignment, :assignment_file]
			pages = :assignment_pages
		when [:submission, :pdf]
			pages = :pages
		end
		if pages.nil?
			raise "Passed unsupported arguments into PageJob: (#{model_type}, #{model_id}, #{file_type})"
		else
			model = model_type.to_s.camelize.constantize.find_by(id: model_id)
			if model
				model.send(file_type).grim.each_with_index do |page, i|
					temp = Tempfile.new ["#{:file_type}_page_#{i + 1}_", ".png"]
					begin
						page.save temp.path
						curr_page = model.send(pages).find_by page_num: (i + 1)
						curr_page.update page_file: temp
					ensure
						temp.close
						temp.unlink
					end
				end
			end
		end
	end
end
