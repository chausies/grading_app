class AddSidToEnrollmentModel < ActiveRecord::Migration
  def change
  	add_column :enrollments, :sid, :string
    add_index :enrollments, :sid
    add_index :enrollments, [:sid, :course_id], unique: true
  end
end
