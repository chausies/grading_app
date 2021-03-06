namespace :db do
  desc "Fill database with sample data"
  task populate: :environment do
    number_of_studs = 49
    number_of_classes = 4
    number_of_hw = 2
    make_users number_of_studs
    make_courses number_of_classes
    signup_users number_of_studs, number_of_classes
    (1..4).each do |course_number|
      create_submit_and_grade_homeworks course_number, number_of_hw
      create_submit_and_begin_grading_homeworks course_number, number_of_hw
    end
  end
end

def make_users number_of_studs
  admin = User.create!(name: "testing",
                       email: "testing@testing.com",
                       password: "testing",
                       password_confirmation: "testing",
                       admin: true)
  number_of_studs.times do |n|
    name  = Faker::Name.name
    email = "#{n+1}@#{n+1}.com"
    password  = "password"
    User.create!(name: name,
                 email: email,
                 password: password,
                 password_confirmation: password)
  end
end

def make_courses number_of_classes
  number_of_classes.times do |n|
    name = "course #{n+1}"
    subject = "subject #{n+1}"
    school = "school #{n+1}"
    Course.create!( name: name,
                    subject: subject,
                    school: school)
  end
end

def signup_users number_of_studs, number_of_classes
  studs = User.all[1..-1]
  courses = Course.all
  studs.each do |stud|
    ([0, 2].map { |x| (x + stud.id)%number_of_classes }).each do |n|
      stud.enroll! courses[n].id, Statuses::STUDENT
    end
  end
end

def create_submit_and_grade_homeworks course_number, number_of_hw
  hws = []
  pdf_url = "http://www.relacweb.org/conferencia/images/documentos/Hoteles_cerca.pdf"
  course = Course.find course_number
  number_of_hw.times do |n|
    hws.append course.assignments.create!( name: "hw#{n+1}",
                                           max_points: 30,
                                           min_points: 0, 
                                           remote_assignment_file_url: pdf_url,
																					 remote_solution_file_url: pdf_url)
  end
  submission_pdf_url = "http://publicsafety.utah.gov/dld/documents/testpdf.pdf"
  studs = course.enrollments.where status: Statuses::STUDENT
  hws.each do |a|
    studs.each do |s|
      a.submissions.create!(enrollment_id: s.id,
                            remote_pdf_url: submission_pdf_url)
    end
    a.assign_gradings(true, 3, 10)
    studs.each do |s|
      badness = s.id*6 % 7
      gradings = s.given_gradings.where assignment_id: a.id
      gradings.each do |g|
        score = (g.gradee.id*9 % 31) + (-badness..badness).to_a.shuffle[0]
        if score < 0
          score = 0
        elsif score > 30
          score = 30
        end
        g.update score: score, finished_grading: true
      end
    end
    a.update finished_grading: true
  end
  course.assign_grades
  course.update_grading_scores  
end

def create_submit_and_begin_grading_homeworks course_number, number_of_hw
  hws = []
  pdf_url = "http://www.relacweb.org/conferencia/images/documentos/Hoteles_cerca.pdf"
  course = Course.find course_number
  number_of_hw.times do |n|
    hws.append course.assignments.create!( name: "quiz#{n+1}",
                                           max_points: 30,
                                           min_points: 0, 
                                           remote_assignment_file_url: pdf_url,
																					 remote_solution_file_url: pdf_url)
  end
  submission_pdf_url = "http://publicsafety.utah.gov/dld/documents/testpdf.pdf"
  studs = course.enrollments.where status: Statuses::STUDENT
  hws.each do |a|
    studs.each do |s|
      a.submissions.create!(enrollment_id: s.id,
                            remote_pdf_url: submission_pdf_url)
    end
    a.assign_gradings(true, 3, 10)
  end
end
