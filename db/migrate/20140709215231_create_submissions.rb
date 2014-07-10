class CreateSubmissions < ActiveRecord::Migration
  def change
    create_table :submissions do |t|
      t.integer :assignment_id
      t.integer :enrollment_id

      t.timestamps
    end
    add_index :submissions, :assignment_id
    add_index :submissions, :enrollment_id
    add_index :submissions, :created_at
  end
end
