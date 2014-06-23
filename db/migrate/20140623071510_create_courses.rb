class CreateCourses < ActiveRecord::Migration
  def change
    create_table :courses do |t|
      t.string :name
      t.string :subject
      t.string :school
      t.timestamps
    end
    add_index :courses, :name
  end
end
