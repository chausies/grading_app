class AddIndicesToAssignmentGradingStatuses < ActiveRecord::Migration
  def change
  	add_index :assignments, :began_grading
  	add_index :assignments, :finished_grading
  end
end
