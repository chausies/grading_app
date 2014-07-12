class EnforceGradingsUnique < ActiveRecord::Migration
  def change
  	add_index :gradings, [:assignment_id, :gradee_id, :grader_id], unique: true
  end
end
