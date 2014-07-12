class AddGradingsToDoToEnrollment < ActiveRecord::Migration
  def change
    add_column :enrollments, :gradings_to_do, :text
  end
end
