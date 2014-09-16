# YAML comes built-in with ruby
require 'yaml'

# load COURSE_DATA_FILE.yaml, assuming it's in the same directory
course = YAML.load_file 'COURSE_DATA_FILE.yaml'

# print out different attribute names for your understanding
puts "'course' has the following attributes"
puts course.keys.join ', '
puts 

assignment = course["assignments"].first
puts "An 'assignment' has the following attributes"
puts assignment.keys.join ', '
puts

participant = course["participants"].first
puts "A 'participant' has the following attributes"
puts participant.keys.join ', '
puts

grading = course["gradings"].first
puts "A 'grading' has the following attributes"
puts grading.keys.join ', '
puts


assignments = course["assignments"] # get an array of all assignments
participants = course["participants"] # get an array of all participants

# loop through the students
participants.each do |participant|
	# make sure the participant is a "student", as opposed to "reader" or "instructor"
  if participant["status"] == "student"
    student = participant
    # compute the average score that student got across all assignments and print it out
    total = 0.0
    assignments.each do |assignment|
      score_on_assignment = student["scores"][assignment["id"]]
      total += score_on_assignment
    end
    avg_assignment_score = total/assignments.length
    puts student["name"] + " got an average assignment score of #{avg_assignment_score}"

    # print out each of student's given gradings on the first assignment and its subparts
    first_assignment = assignments.first
    student["gradings_by"].each do |grading| # "gradings_for" is for received gradings
      if grading["assignment"]["id"] == first_assignment["id"]
        other_student = grading["gradee"]
        # student == grading["grader"]
        assignment_name = first_assignment["name"]
        subpart = grading["subpart"]
        if not subpart.nil?
          assignment_name.concat ", Part (#{subpart["index"]}): #{subpart["name"]}"
        end
        puts "For " + assignment_name
        puts "\t#{student["name"]} gave a score of #{grading["score"]}/#{first_assignment["max_points"]} to #{other_student["name"]}"
      end
    end
  end
end
