class CreateGrades < ActiveRecord::Migration
  def change
    create_table :grades do |t|
      t.integer :assignment_id
      t.integer :enrollment_id
      t.integer :score
      t.timestamps
    end
    add_index :grades, :assignment_id
    add_index :grades, :enrollment_id
    add_index :grades, [:assignment_id, :enrollment_id], unique: true
  end
end
