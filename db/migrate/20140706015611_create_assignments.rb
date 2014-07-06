class CreateAssignments < ActiveRecord::Migration
  def change
    create_table :assignments do |t|
      t.string :name
      t.integer :course_id
      t.timestamps
    end
    add_index :assignments, :course_id
  end
end
