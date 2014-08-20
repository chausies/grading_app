class ChangeFilesForAssignment < ActiveRecord::Migration
  def change
		remove_column :assignments, :pdf
    add_column :assignments, :assignment_file, :string
    add_column :assignments, :solution_file, :string
  end
end
