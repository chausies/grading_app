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

ActiveRecord::Schema.define(version: 20140629052138) do

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
    t.string   "SID"
  end

  add_index "enrollments", ["SID"], name: "index_enrollments_on_SID"
  add_index "enrollments", ["course_id"], name: "index_enrollments_on_course_id"
  add_index "enrollments", ["participant_id", "course_id"], name: "index_enrollments_on_participant_id_and_course_id", unique: true
  add_index "enrollments", ["participant_id"], name: "index_enrollments_on_participant_id"

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
