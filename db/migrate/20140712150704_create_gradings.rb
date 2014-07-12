class CreateGradings < ActiveRecord::Migration
  def change
    create_table :gradings do |t|
      t.integer :assignment_id
      t.integer :gradee
      t.integer :grader

      t.timestamps
    end
    add_index :gradings, :assignment_id
    add_index :gradings, :gradee
    add_index :gradings, :grader
  end
end
