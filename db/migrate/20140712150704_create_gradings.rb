class CreateGradings < ActiveRecord::Migration
  def change
    create_table :gradings do |t|
      t.integer :assignment_id
      t.integer :gradee_id
      t.integer :grader_id

      t.timestamps
    end
    add_index :gradings, :assignment_id
    add_index :gradings, :gradee_id
    add_index :gradings, :grader_id
  end
end
