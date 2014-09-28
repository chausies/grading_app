class Course < ActiveRecord::Base
  # Attributes: name, subject, school
  include ActionView::Helpers::TextHelper
  
  default_scope -> { order('id ASC') }
	scope :persisted, -> { where "id IS NOT NULL" }

  has_many :enrollments,  foreign_key: "course_id", dependent: :destroy
  has_many :participants, through: :enrollments
  has_many :assignments,  dependent: :destroy

  validates :name, presence: true, length: { minimum: 2, maximum: 50 }
  validates :school, presence: true, length: { minimum: 2, maximum: 50 }

  after_create :enroll_admins

  def import(file)
  # Returns true if import successful, else returns an error message
    message = ""
    if file.nil? or file.content_type != 'text/csv'
      return message = "We currently only support csv files."
    end
    student_params = {
      "name"                  =>  "name",
      "student name"          =>  "name",
      "sid"                   =>  "sid",
      "student id number"     =>  "sid",
      "student id"            =>  "sid",
      "id #"                  =>  "sid",
      "identification number" =>  "sid",
      "id number"             =>  "sid",
      "email"                 =>  "email",
      "email address"         =>  "email",
      "address"               =>  "email",
      "student email"         =>  "email",
      "status"                =>  "status",
      "role"                  =>  "status",
      "type"                  =>  "status"
    }
    bad_strings = []
    match = lambda do |string|
      string.downcase!
      match = student_params.max { |a,b| a[0].levenshtein_similar(string) <=> b[0].levenshtein_similar(string) }
      if string.levenshtein_similar(match[0]) < 0.4
        bad_strings.append string
      end
      match[1].to_sym
    end
    CSV.foreach file.path, headers: true, header_converters: match do |row|
      break if !bad_strings.empty?
      stud_hash = row.to_hash.each { |_, str| str.strip! }
      if stud_hash[:email].nil?
        return message = "Email required for the following student: " + stud_hash.to_s
      end
      if stud_hash[:name].blank?
        stud_hash[:name] = "testing"
      end
      unless student = User.find_by(email: stud_hash[:email])
        student = User.create email: stud_hash[:email], name: stud_hash[:name], password: "testing", password_confirmation: "testing"
        if student.errors.any?
          return message = "Error for following student: " + stud_hash.to_s + ". Error content: " + student.errors.full_messages.first
        end
      end
      if student.enrolled?(id)
        next
      end
      begin
        if stud_hash[:status].blank?
          stud_hash[:status] = Statuses::STUDENT
        else
          stud_hash[:status] = Statuses.string_to_status stud_hash[:status]
          if stud_hash[:status].nil?
            stud_hash[:status] = Statuses::STUDENT
          end
        end
        student.enroll! id, stud_hash[:status], stud_hash[:sid]
      rescue
        return message = "Error for the following student: " + stud_hash.to_s + ". Probably because SID matches that of another student."
      end
    end
    if !bad_strings.empty?
      message = "Couldn't find good match for the following #{pluralize(bad_strings.length, "parameter")}: " + bad_strings.join(", ")
    end
    if message.empty?
      true
    else
      message
    end
  end

	def to_csv options = {}
		@students = Enrollment.all.where course_id: self.id, status: Statuses::STUDENT
		CSV.generate do |csv|
			header = ["Student name", "SID", "email"]
			self.assignments.all.each do |assignment|
				header << assignment.name
				if assignment.subparts.all.any?
					assignment.subpart_leaves.each do |subpart|
						header << "Part (#{subpart.index}): #{subpart.name}"
					end
				end 
			end
			csv << header
			@students.each do |stud|
				row = [stud.participant.name, stud.sid, stud.participant.email]
				self.assignments.all.each do |assignment|
					row << stud.score_for(assignment.id)
					if assignment.subparts.all.any?
						assignment.subpart_leaves.each do |subpart|
							row << stud.score_for(assignment.id, subpart.id)
						end
					end 
				end
				csv << row
			end
		end
	end

	def yaml_dict
		helper_dict = {}
		course_dict = {}
		course_dict["name"] = self.name
		course_dict["subject"] = self.subject
		course_dict["school"] = self.school
		participants = []
		self.enrollments.all.each do |participant|
			participant_dict = {}
			participant_dict["id"] = "Participant #{participant.id}, #{participant.participant.name}"
			participant_dict["name"] = participant.participant.name
			participant_dict["email"] = participant.participant.email
			participant_dict["status"] = Statuses.status_to_string participant.status
			participant_dict["sid"] = participant.sid
			participant_dict["grading_score"] = participant.grading_score.to_f
			scores = {}
			self.assignments.all.each do |assignment|
				scores["Assignment #{assignment.id}, #{assignment.name}"] = participant.score_for(assignment.id).to_f
				fringe = assignment.subparts.all.to_a
				while fringe.any?
					subpart = fringe.shift
					scores["Subpart #{subpart.id}, Part (#{subpart.index})"] = participant.score_for(assignment.id, subpart.id).to_f
					fringe.unshift subpart.children.all.to_a
				end
			end
			participant_dict["scores"] = scores
			participant_dict["gradings_by"] = []
			participant_dict["gradings_for"] = []
			participants << participant_dict
			helper_dict[participant] = participant_dict
		end
		course_dict["participants"] = participants
		course_dict["gradings"] = []
		assignments = []
		self.assignments.all.reverse.each do |assignment|
			assignment_dict = {}
			assignment_dict["id"] = "Assignment #{assignment.id}, #{assignment.name}"
			assignment_dict["name"] = assignment.name
			assignment_dict["min_points"] = assignment.min_points.to_f
			assignment_dict["max_points"] = assignment.max_points.to_f
			assignment_dict["subparts"] = []
			fringe = assignment.subparts.all.to_a
			fringe.map! { |s| [assignment_dict, s] }
			while fringe.any?
				parent, subpart = fringe.shift
				subpart_dict = {}
				subpart_dict["id"] = "Subpart #{subpart.id}, Part (#{subpart.index})"
				subpart_dict["name"] = subpart.name
				subpart_dict["index"] = subpart.index
				subpart_dict["min_points"] = subpart.min_points.to_f
				subpart_dict["max_points"] = subpart.max_points.to_f
				subpart_dict["gradings"] = []
				subpart_dict["parent"] = parent
				subpart_dict["subparts"] = []
				parent["subparts"] << subpart_dict
				helper_dict[subpart] = subpart_dict
				children = subpart.children.all.to_a
				children.map! { |s| [subpart_dict, s] }
				fringe.unshift children
			end
			gradings = []
			assignment.gradings.all.each do |grading|
				grading_dict = {}
				grading_dict["id"] = "Grading #{grading.id}"
				grading_dict["assignment"] = assignment_dict
				grading_dict["subpart"] = helper_dict[grading.subpart]
				grading_dict["gradee"] = helper_dict[grading.gradee]
				grading_dict["grader"] = helper_dict[grading.grader]
				grading_dict["score"] = grading.score.to_f
				gradings << grading_dict
				if grading_dict["subpart"]
					grading_dict["subpart"]["gradings"] << grading_dict
				end
				grading_dict["gradee"]["gradings_for"] << grading_dict
				grading_dict["grader"]["gradings_by"] << grading_dict
				course_dict["gradings"] << grading_dict
			end
			assignment_dict["gradings"] = gradings
			assignments << assignment_dict
		end
		course_dict["assignments"] = assignments
		course_dict.to_yaml
	end

	def execute_command(command, assignment_file=nil, solution_file=nil)
    # 'command' should be of the form { "key" => "value" }
		val = [true, []]
		self.transaction do
			command_name = command.keys[0]
			command_contents = command.values[0]
			case command_name
			when "new_assignment"
				if not (assignment_file or solution_file)
					val = false, (assignment_file ? "" : "No assignment file submitted. ") + (solution_file ? "" : "No solution file submitted. ")
				else
					ass_cmds = command_contents
					ass_params = { 
												name: ass_cmds["name"], 
												assignment_file: assignment_file, 
												solution_file: solution_file
											} 
					unless ass_cmds["subparts"]
						if not (ass_cmds["min_points"] and ass_cmds["max_points"])
							val = false, "An assignment without subparts must have its min and max points specified"
						else
							ass_params.merge! min_points: ass_cmds["min_points"], max_points: ass_cmds["max_points"]
						end
					end
					if val[0]
						new_assignment = self.assignments.create ass_params 
						if new_assignment.errors.any?
							val = false, new_assignment.errors.full_messages
						else
							if not (subparts = ass_cmds["subparts"])
								val = true, "Successfully created assignment!"
							else
								if not (subparts.map { |s| s["index"] }).all?
									bad_subparts = subparts.select { |s| not s["index"] }
									val = false, "#{pluralize(bad_subparts.size, "bad subpart")}: " + bad_subparts.join(', ')
								elsif (repeats = subparts.select { |x| subparts.count(x) > 1 } .uniq).size > 0
										val = false, "For #{ass_cmds["name"]}, the following "\
																	"#{pluralize_phrase(repeats.size, "subpart index", "isn't", "aren't")} "\
																	"unique for the assignment: " + repeats.join(', ')
								else
									subparts.sort! do |s1, s2| 
										(s1["index"].zip(s2["index"]).map { |a, b| a <=> b } .find { |c| c and c.nonzero? }) or s1["index"].size <=> s2["index"].size
									end
									helper_dict = {}
									current_index = [1]
									while current_index.any?
										current_subpart = subparts.find { |s| s["index"] == current_index }
										if current_subpart.nil?
											current_index.pop
											current_index[current_index.size - 1] += 1 if current_index.any?
										else
											parent = Subpart.find_by id: helper_dict[current_index.first(current_index.size-1)]
											subpart_params = { name: current_subpart["name"], 
																				 min_points: current_subpart["min_points"], 
																				 max_points: current_subpart["max_points"] }
											if parent
												child = parent.children.create subpart_params
											else
												child = new_assignment.subparts.create subpart_params
											end
											if child.errors.any?
												val = false, child.errors.full_messages
												break
											else
												helper_dict[current_index] = child.id
												current_index += [1]
											end
										end
									end
									if val[0] == true
										if not (subparts.map { |s| new_assignment.get_subpart(s["index"]) }).all?
											val = false, "Indices of subparts weren't specified properly. Please check them."
										else
											helper_dict = helper_dict.invert
											new_assignment.subpart_leaves.each do |subpart|
												pages = (subparts.find { |s| s["index"] == helper_dict[subpart.id] })["pages"]
												pages.each do |page_num|
													page = new_assignment.solution_pages.find_by page_num: page_num
													if not page
														val = false, "The solution file provided doesn't have a page #{page_num}"
														break
													else
														subpart.pages << page
													end
												end
												subpart.save
											end
											if val[0]
												val = true, "Successfully created assignment with subparts!"
											end
										end
									end
								end
							end
						end
					end
				end
			else
				val = false, "Unrecognized command #{command_name}"
			end
			unless val[0]
				raise ActiveRecord::Rollback
			end
		end
		val
	end

  def assign_grades
    assignments = self.assignments.where finished_grading: true
    enrollments = self.enrollments
    assignments.each do |assignment|
			leaves = assignment.subpart_leaves
			leaves = [nil] if leaves.empty?
			leaves.each do |subpart|
				touched_enrollments = []
				grading_hash = {}
				actual_subpart = subpart
				subpart ||= assignment
				subpart.gradings.each do |g|
					if g.finished?
						grading_hash[g.gradee] ||= []
						grading_hash[g.gradee].append g.score
					end
				end
				grading_hash.each do |enrollment, assigned_grades|
					enrollment.assign_grade(assignment.id, (actual_subpart ? subpart.id : nil), assigned_grades.sum.to_f/assigned_grades.size)
					touched_enrollments.append enrollment.id
				end
				touched_enrollments = touched_enrollments.to_set
				gets_zero = enrollments.to_a.delete_if { |e| touched_enrollments.member? e.id }
				gets_zero.each { |e| e.assign_grade(assignment.id, (actual_subpart ? subpart.id : nil), subpart.min_points) }
			end
    end
  end

  def update_grading_scores
    assignments = self.assignments.where(finished_grading: true).map { |assignment| assignment.id }
    self.enrollments.where(status: [Statuses::STUDENT, Statuses::READER]).each do |e|
      gradings = e.given_gradings.where assignment_id: assignments, finished_grading: true
      if gradings.any?
        relative_errors = gradings.map do |g| 
					subpart = g.subpart || g.assignment # subpart is the assignment if subpart is nil
					if subpart.max_points == subpart.min_points
						0
					else
						(g.score - g.gradee.score_for(g.assignment_id, g.subpart_id)).abs.to_f/(subpart.max_points - subpart.min_points)
					end
				end
        e.update grading_score: 100 - 100*relative_errors.sum/relative_errors.size
      end
    end
  end

  private
    def enroll_admins
      admin_users = User.where admin: true
      admin_users.each { |admin| admin.enroll! self, Statuses::ADMIN }
    end

		# tells if a subpart with index array p is the parent of a subpart with index array c
		def child_helper p, c
			if p.size + 1 == c.size and p == c.first(p.size)
				true
			else
				false
			end
		end

end
