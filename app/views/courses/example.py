# To get YAML for python, run 'pip install pyyaml'
import yaml

# load COURSE_DATA_FILE.yaml, assuming it's in the same directory
stream = open('COURSE_DATA_FILE.yaml', 'r')
# 'course' is a simple dictionary to access all course data
course = yaml.load(stream)

# print out different attribute names for your understanding
print "'course' has the following attributes"
print ', '.join(course.keys())
print 

assignment = course["assignments"][0]
print "An 'assignment' has the following attributes"
print ', '.join(assignment.keys())
print

participant = course["participants"][0]
print "A 'participant' has the following attributes"
print ', '.join(participant.keys())
print

grading = course["gradings"][0]
print "A 'grading' has the following attributes"
print ', '.join(grading.keys())
print


assignments = course["assignments"] # get an array of all assignments
participants = course["participants"] # get an array of all participants

# loop through the students
for participant in participants: 
  # make sure the participant is a "student", as opposed to "reader" or "instructor"
  if participant["status"] == "student":
    student = participant
    # compute the average score that student got across all assignments and print it out
    total = 0.0
    for assignment in assignments:
      score_on_assignment = student["scores"][assignment["id"]]
      total += score_on_assignment
    avg_assignment_score = total/len(assignments)
    print "%s got an average assignment score of %.2f" % (student["name"], avg_assignment_score)

    # print out each of student's given gradings on the first assignment and its subparts
    first_assignment = assignments.first
    for grading in student["gradings_by"]: # "gradings_for" is for received gradings
      if grading["assignment"]["id"] == first_assignment["id"]:
        other_student = grading["gradee"]
        # student == grading["grader"]
        assignment_name = first_assignment["name"]
        subpart = grading["subpart"]
        if not (subpart == None):
          assignment_name += ", Part (#{subpart["index"]}): #{subpart["name"]}"
        print "For " + assignment_name
        print "\t%s gave a score of %.2f/%.2f to %s" % (student["name"], grading["score"], first_assignment["max_points"], other_student["name"])
