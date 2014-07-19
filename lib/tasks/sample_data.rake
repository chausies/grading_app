namespace :db do
  desc "Fill database with sample data"
  task populate: :environment do
    number_of_studs = 99
    number_of_classes = 4
    course_number = 1
    number_of_hw = 3
    make_users number_of_studs
    make_courses number_of_classes
    signup_users number_of_studs, number_of_classes
    create_submit_and_grade_homeworks course_number, number_of_hw
    create_submit_and_begin_grading_homeworks course_number, number_of_hw
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
    name = "name #{n+1}"
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
  studs.each { |stud| stud.enroll! courses[[0, 2].map { |x| (x + stud.id)%number_of_classes }].id, Statuses::STUDENT }
end

def create_submit_and_grade_homeworks course_number, number_of_hw
  hws = []
  pdf_url = "https://s3.amazonaws.com/piazza-resources/hoab39slmgz2pe/hse0m40ddob1xw/hw3.pdf?AWSAccessKeyId=AKIAJKOQYKAYOBKKVTKQ&Expires=1405816818&Signature=7s2MDHB3xcihHOPkrQYk8i066Zw%3D"
  course = Course.find course_number
  number_of_hw.times do |n|
    hws.append course.assignments.create!( name: "hw#{n+1}",
                                           max_points: 30,
                                           min_points: 0, 
                                           remote_pdf_url: pdf_url)
  end
  submission_pdf_url = "https://s3.amazonaws.com/piazza-resources/hoab39slmgz2pe/hsnv6jt55641zc/hw3sols.pdf?AWSAccessKeyId=AKIAJKOQYKAYOBKKVTKQ&Expires=1405816864&Signature=18Cb9YkLlmhMWxl7S%2BVV2E7ZcCs%3D"
  studs = course.enrollments.where status: Statuses::STUDENT
  hws.each do |a|
    studs.each do |s|
      a.submissions.create!(enrollment_id: s.id,
                            remote_pdf_url: submission_pdf_url)
    end
    a.assign_gradings
    studs.each do |s|
      badness = s.id*4 % 5
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
  end
  course.assign_grades
  course.update_grading_scores
  end
end

def create_submit_and_begin_grading_homeworks course_number, number_of_hw
  hws = []
  pdf_url = "https://s3.amazonaws.com/piazza-resources/hoab39slmgz2pe/hse0m40ddob1xw/hw3.pdf?AWSAccessKeyId=AKIAJKOQYKAYOBKKVTKQ&Expires=1405816818&Signature=7s2MDHB3xcihHOPkrQYk8i066Zw%3D"
  course = Course.find course_number
  number_of_hw.times do |n|
    hws.append course.assignments.create!( name: "quiz#{n+1}",
                                           max_points: 30,
                                           min_points: 0, 
                                           remote_pdf_url: pdf_url)
  end
  submission_pdf_url = "https://s3.amazonaws.com/piazza-resources/hoab39slmgz2pe/hsnv6jt55641zc/hw3sols.pdf?AWSAccessKeyId=AKIAJKOQYKAYOBKKVTKQ&Expires=1405816864&Signature=18Cb9YkLlmhMWxl7S%2BVV2E7ZcCs%3D"
  studs = course.enrollments.where status: Statuses::STUDENT
  hws.each do |a|
    studs.each do |s|
      a.submissions.create!(enrollment_id: s.id,
                            remote_pdf_url: submission_pdf_url)
    end
    a.assign_gradings
  end
end