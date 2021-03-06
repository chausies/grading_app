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

ActiveRecord::Schema.define(version: 20140929091059) do

  create_table "assignments", force: true do |t|
    t.string   "name"
    t.integer  "course_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "max_points"
    t.decimal  "min_points"
    t.boolean  "began_grading",    default: false
    t.boolean  "finished_grading", default: false
    t.string   "assignment_file"
    t.string   "solution_file"
  end

  add_index "assignments", ["began_grading"], name: "index_assignments_on_began_grading"
  add_index "assignments", ["course_id"], name: "index_assignments_on_course_id"
  add_index "assignments", ["finished_grading"], name: "index_assignments_on_finished_grading"

  create_table "courses", force: true do |t|
    t.string   "name"
    t.string   "subject"
    t.string   "school"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "courses", ["name"], name: "index_courses_on_name"

  create_table "delayed_jobs", force: true do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority"

  create_table "enrollments", force: true do |t|
    t.integer  "participant_id"
    t.integer  "course_id"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "sid"
    t.float    "grading_score"
  end

  add_index "enrollments", ["course_id"], name: "index_enrollments_on_course_id"
  add_index "enrollments", ["participant_id", "course_id"], name: "index_enrollments_on_participant_id_and_course_id", unique: true
  add_index "enrollments", ["participant_id"], name: "index_enrollments_on_participant_id"
  add_index "enrollments", ["sid", "course_id"], name: "index_enrollments_on_sid_and_course_id", unique: true
  add_index "enrollments", ["sid"], name: "index_enrollments_on_sid"

  create_table "grades", force: true do |t|
    t.integer  "assignment_id"
    t.integer  "enrollment_id"
    t.integer  "score"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "subpart_id"
  end

  add_index "grades", ["assignment_id", "subpart_id", "enrollment_id"], name: "grade_uniqueness_index", unique: true
  add_index "grades", ["assignment_id"], name: "index_grades_on_assignment_id"
  add_index "grades", ["enrollment_id"], name: "index_grades_on_enrollment_id"
  add_index "grades", ["subpart_id"], name: "index_grades_on_subpart_id"

  create_table "gradings", force: true do |t|
    t.integer  "assignment_id"
    t.integer  "gradee_id"
    t.integer  "grader_id"
    t.decimal  "score"
    t.boolean  "finished_grading", default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "subpart_id"
  end

  add_index "gradings", ["assignment_id", "subpart_id", "gradee_id", "grader_id"], name: "grading_uniqueness_index", unique: true
  add_index "gradings", ["assignment_id"], name: "index_gradings_on_assignment_id"
  add_index "gradings", ["finished_grading"], name: "index_gradings_on_finished_grading"
  add_index "gradings", ["gradee_id"], name: "index_gradings_on_gradee_id"
  add_index "gradings", ["grader_id"], name: "index_gradings_on_grader_id"
  add_index "gradings", ["subpart_id"], name: "index_gradings_on_subpart_id"

  create_table "meta_jobs", force: true do |t|
    t.string   "identifier"
    t.integer  "job_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "meta_jobs", ["identifier"], name: "index_meta_jobs_on_identifier"
  add_index "meta_jobs", ["job_id"], name: "index_meta_jobs_on_job_id"

  create_table "pages", force: true do |t|
    t.integer  "assignment_id"
    t.integer  "solution_id"
    t.integer  "submission_id"
    t.integer  "page_num"
    t.string   "page_file"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "pages", ["assignment_id"], name: "index_pages_on_assignment_id"
  add_index "pages", ["solution_id"], name: "index_pages_on_solution_id"
  add_index "pages", ["submission_id"], name: "index_pages_on_submission_id"

  create_table "pages_subparts_relationships", force: true do |t|
    t.integer "page_id"
    t.integer "subpart_id"
  end

  add_index "pages_subparts_relationships", ["page_id", "subpart_id"], name: "index_pages_subparts_relationships_on_page_id_and_subpart_id"
  add_index "pages_subparts_relationships", ["page_id"], name: "index_pages_subparts_relationships_on_page_id"
  add_index "pages_subparts_relationships", ["subpart_id", "page_id"], name: "index_pages_subparts_relationships_on_subpart_id_and_page_id"
  add_index "pages_subparts_relationships", ["subpart_id"], name: "index_pages_subparts_relationships_on_subpart_id"

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

  create_table "subparts", force: true do |t|
    t.string   "name"
    t.integer  "parent_id"
    t.string   "parent_type"
    t.decimal  "max_points"
    t.decimal  "min_points"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "subparts", ["parent_id"], name: "index_subparts_on_parent_id"

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
