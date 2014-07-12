class EnforceGradingsUnique < ActiveRecord::Migration
  def change
  	add_index :gradings, [:assignment_id, :gradee, :grader], unique: true
  end
end
