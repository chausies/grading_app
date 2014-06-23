namespace :db do
  desc "Fill database with sample data"
  task populate: :environment do
    make_users
    make_courses
    signup_users
  end
end

def make_users
  admin = User.create!(name: "Example User",
                       email: "example@railstutorial.org",
                       password: "foobar",
                       password_confirmation: "foobar",
                       admin: true)
  99.times do |n|
    name  = Faker::Name.name
    email = "example-#{n+1}@railstutorial.org"
    password  = "password"
    User.create!(name: name,
                 email: email,
                 password: password,
                 password_confirmation: password)
  end
end

def make_courses
  number_of_classes = 4
  number_of_classes.times do |n|
    name = "name #{n+1}"
    subject = "subject #{n+1}"
    school = "school #{n+1}"
    Course.create!( name: name,
                    subject: subject,
                    school: school)
  end
end

def signup_users
  number_of_classes = 4
  number_of_studs = 99
  admin = User.find(1)
  studs = User.all[1..-1]
  courses = Course.all
  courses.each { |course| admin.enroll! course.id, Statuses::ADMIN }
  studs.each { |stud| stud.enroll! courses[stud.id%number_of_classes].id, Statuses::STUDENT }
end