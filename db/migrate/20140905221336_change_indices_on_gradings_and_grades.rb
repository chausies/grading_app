class ChangeIndicesOnGradingsAndGrades < ActiveRecord::Migration
  def change
		remove_index :gradings, column: [:assignment_id, :gradee_id, :grader_id]
		remove_index :grades, column: [:assignment_id, :enrollment_id]
		add_index :gradings, :subpart_id
		add_index :grades, :subpart_id
		add_index :gradings, [:assignment_id, :subpart_id, :gradee_id, :grader_id], unique: true, name: "grading_uniqueness_index"
		add_index :grades, [:assignment_id, :subpart_id, :enrollment_id], unique: true, name: "grade_uniqueness_index"
  end
end
