class CreateGradings < ActiveRecord::Migration
  def change
    create_table :gradings do |t|
      t.integer :assignment_id
      t.integer :gradee_id
      t.integer :grader_id
      t.decimal :score
      t.boolean :finished_grading, default: false
      t.timestamps
    end
    add_index :gradings, :assignment_id
    add_index :gradings, :gradee_id
    add_index :gradings, :grader_id
    add_index :gradings, :finished_grading
    add_index :gradings, [:assignment_id, :gradee_id, :grader_id], unique: true
  end
end
