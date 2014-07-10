class CreateSubmissions < ActiveRecord::Migration
  def change
    create_table :submissions do |t|
      t.integer :assignment_id
      t.integer :enrollment_id

      t.timestamps
    end
    add_index :submissions, [:assignment_id, :enrollment_id, :created_at]
  end
end
