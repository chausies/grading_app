class CreateEnrollments < ActiveRecord::Migration
  def change
    create_table :enrollments do |t|
      t.integer :participant_id
      t.integer :course_id
      t.string :status

      t.timestamps
    end
    add_index :enrollments, :participant_id
    add_index :enrollments, :course_id
    add_index :enrollments, [:participant_id, :course_id], unique: true
  end
end
