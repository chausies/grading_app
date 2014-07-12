# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140712181436) do

  create_table "assignments", force: true do |t|
    t.string   "name"
    t.integer  "course_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "pdf"
    t.decimal  "max_points"
    t.decimal  "min_points"
    t.boolean  "began_grading", default: false
  end

  add_index "assignments", ["course_id"], name: "index_assignments_on_course_id"

  create_table "courses", force: true do |t|
    t.string   "name"
    t.string   "subject"
    t.string   "school"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "courses", ["name"], name: "index_courses_on_name"

  create_table "enrollments", force: true do |t|
    t.integer  "participant_id"
    t.integer  "course_id"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "sid"
    t.text     "gradings_to_do"
  end

  add_index "enrollments", ["course_id"], name: "index_enrollments_on_course_id"
  add_index "enrollments", ["participant_id", "course_id"], name: "index_enrollments_on_participant_id_and_course_id", unique: true
  add_index "enrollments", ["participant_id"], name: "index_enrollments_on_participant_id"
  add_index "enrollments", ["sid", "course_id"], name: "index_enrollments_on_sid_and_course_id", unique: true
  add_index "enrollments", ["sid"], name: "index_enrollments_on_sid"

  create_table "gradings", force: true do |t|
    t.integer  "assignment_id"
    t.integer  "gradee"
    t.integer  "grader"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "score"
  end

  add_index "gradings", ["assignment_id", "gradee", "grader"], name: "index_gradings_on_assignment_id_and_gradee_and_grader", unique: true
  add_index "gradings", ["assignment_id"], name: "index_gradings_on_assignment_id"
  add_index "gradings", ["gradee"], name: "index_gradings_on_gradee"
  add_index "gradings", ["grader"], name: "index_gradings_on_grader"

  create_table "submissions", force: true do |t|
    t.integer  "assignment_id"
    t.integer  "enrollment_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "pdf"
  end

  add_index "submissions", ["assignment_id"], name: "index_submissions_on_assignment_id"
  add_index "submissions", ["created_at"], name: "index_submissions_on_created_at"
  add_index "submissions", ["enrollment_id"], name: "index_submissions_on_enrollment_id"

  create_table "users", force: true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "password_digest"
    t.string   "remember_token"
    t.boolean  "admin",           default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["remember_token"], name: "index_users_on_remember_token"

end
