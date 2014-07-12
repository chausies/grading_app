class CreateGradings < ActiveRecord::Migration
  def change
    create_table :gradings do |t|
      t.integer :assignment_id
      t.integer :grading_for
      t.integer :grading_by

      t.timestamps
    end
    add_index :gradings, :assignment_id
    add_index :gradings, :grading_for
    add_index :gradings, :grading_by
  end
end
